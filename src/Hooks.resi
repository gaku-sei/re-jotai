let use: Atom.t<'value, Atom.Permissions.rw> => ('value, ('value => 'value) => unit)

let useReadable: Jotai.Atom.t<'a, [> Jotai.Atom.Permissions.r]> => 'a
