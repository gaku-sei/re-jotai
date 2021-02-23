@module("jotai")
external use: Atom.t<'value, 'setValue, Atom.Permissions.rw> => ('value, 'setValue => unit) =
  "useAtom"

@module("jotai")
external useReadableInternal: Atom.t<'value, 'setValue, [> Atom.Permissions.r]> => (
  'value,
  Atom.void,
) = "useAtom"

@module("jotai")
external useWritableInternal: Atom.t<'value, 'setValue, [> Atom.Permissions.w]> => (
  Atom.void,
  'setValue => unit,
) = "useAtom"

let useReadable = atom => {
  let (value, _: Atom.void) = useReadableInternal(atom)

  value
}

let useWritable = atom => {
  let (_: Atom.void, setValue) = useWritableInternal(atom)

  setValue
}
