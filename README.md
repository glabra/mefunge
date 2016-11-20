Mefunge
-------

This is an Befunge-93 interpreter written in GNU m4 and POSIX shell script.

# Dependency
- POSIX-compliant shell
- [GNU m4](https://www.gnu.org/software/m4/m4.html) 1.4.17 or later

Tested under Alpine Linux 3.4.4

# How-to use
```sh
./befunge < [befunge source file]
```

# Limitation
- `&`, `~`, and `?` operators are not implemented.
- source file must not contain `{-` character sequence.
- operator `,` is replaced with `;` due to m4's obfuscated syntax.
- `,` in source file is replaced into `;` by wrapper script.
- noeol file is not supported. This is wrapper script's limitation.

