#ifdef __GNUC__
#define UNUSED(x) UNUSED_ ## x __attribute__((__unused__))
#else
#define UNUSED(x) UNUSED_ ## x
#endif

#include "erl_nif.h"
#include <string.h>
#include <sys/param.h>

static ErlNifResourceType *poke_resource_type = NULL;

typedef struct {
  char *data;
  size_t size;
} poke_ptr;

static ERL_NIF_TERM make_ok_tuple(ErlNifEnv *env, ERL_NIF_TERM value)
{
  return enif_make_tuple2(env, enif_make_atom(env, "ok"), value);
}

static ERL_NIF_TERM make_error_tuple(ErlNifEnv *env, const char *reason)
{
  return enif_make_tuple2(env, enif_make_atom(env, "error"), enif_make_atom(env, reason));
}

ERL_NIF_TERM new(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  poke_ptr *ptr;
  ERL_NIF_TERM poke_ref;
  int poke_size;
  ErlNifBinary binary;

  ptr = enif_alloc_resource(poke_resource_type, sizeof(poke_ptr));
  if(!ptr)
    return make_error_tuple(env, "no_memory");

  if(enif_get_int(env, argv[0], &poke_size)) {
    ptr->size = poke_size;
    ptr->data = enif_alloc(poke_size);
    memset(ptr->data, 0, ptr->size);
  } else if (enif_inspect_iolist_as_binary(env, argv[0], &binary)) {
    ptr->size = binary.size;
    ptr->data = enif_alloc(ptr->size);
    memcpy(ptr->data, binary.data, binary.size);
  } else {
    return enif_make_badarg(env);
  }

  poke_ref = enif_make_resource(env, ptr);
  enif_release_resource(ptr);

  return make_ok_tuple(env, poke_ref);
}

ERL_NIF_TERM fetch(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  poke_ptr *ptr;

  if (argc != 1) {
    return enif_make_badarg(env);
  }
  if(!enif_get_resource(env, argv[0], poke_resource_type, (void**) &ptr)) {
    return enif_make_badarg(env);
  }

  return enif_make_resource_binary(env, ptr, ptr->data, ptr->size);
}

ERL_NIF_TERM poke(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  poke_ptr *ptr;
  int pos, ch;
  ErlNifBinary binary;

  if (argc != 3) {
    return enif_make_badarg(env);
  }
  if(!enif_get_resource(env, argv[0], poke_resource_type, (void**) &ptr)) {
    return enif_make_badarg(env);
  }
  if (!enif_get_int(env, argv[1], &pos)) {
    return enif_make_badarg(env);
  }
  if (enif_get_int(env, argv[2], &ch)) {
    // set single byte
    ptr->data[pos] = ch;
  }
  else if (enif_inspect_iolist_as_binary(env, argv[2], &binary)) {
    // set a range
    memcpy(ptr->data + pos, binary.data, MIN(binary.size, ptr->size - pos));

  } else {
    return enif_make_badarg(env);
  }

  return enif_make_atom(env, "ok");
}

static void destruct_poke(ErlNifEnv *UNUSED(env), void *arg) {
  poke_ptr *ptr = (poke_ptr *)arg;
  // FIXME
}

static int on_load(ErlNifEnv* env, void** UNUSED(priv), ERL_NIF_TERM UNUSED(info))
{
  poke_resource_type = enif_open_resource_type(
    env,
    "poke_nif",
    "poke_transaction_type",
    destruct_poke,
    ERL_NIF_RT_CREATE,
    NULL
    );

  if (!poke_resource_type) {
    return -1;
  }

  return 0;
}

static ErlNifFunc nif_funcs[] = {
  {"new", 1, new},
  {"fetch", 1, fetch},
  {"poke", 3, poke}
};

ERL_NIF_INIT(Elixir.Poke.Nif, nif_funcs, on_load, NULL, NULL, NULL);
