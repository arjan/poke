# poke — Memory management in a NIF.

⚠️  Use at your own risk.

## Usage:

```
{:ok, r} = Poke.new("tonći")
"tonći" = Poke.fetch(r)
:ok = Poke.poke(r, 0, ?T)
"Tonći" = Poke.fetch(r)
```
