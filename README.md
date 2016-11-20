Mefunge
-------

This is an Befunge-93 interpreter written in GNU m4 and POSIX shell script.

# Dependency
- POSIX-compliant shell
- [GNU m4](https://www.gnu.org/software/m4/m4.html) 1.4.17 or later

Tested under Alpine Linux 3.4.4

# How-to use
```sh
./befunge hoge.bf
```

# Limitations
- `?` operators is not implemented.
- operator `,` is replaced with `;` due to m4's obfuscated syntax.
- source file must not contain `{-` or `,` character sequence.
- `,` in source file is replaced into `;` by wrapper script.
- modify program (`p`) with `null` or characters which is not in extended-ASCII is not supported.
- noeol file is not supported. This is wrapper script's limitation.

# License
MIT License. For detail, see `LICENSE`.
