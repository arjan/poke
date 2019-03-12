# poke — Memory management in a NIF.

⚠️  Use at your own risk.

## Usage:

```
{:ok, r} = Nif.new("tonći")
"tonći" = Nif.fetch(r)
:ok = Nif.poke(r, 0, ?T)
"Tonći" = Nif.fetch(r)
```
