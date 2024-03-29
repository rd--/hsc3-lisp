import qualified Music.Theory.Io as Io {- hmt-base -}
import qualified Music.Theory.Opt as Opt {- hmt-base -}

import qualified Language.Smalltalk.Stc.Translate as Stc {- stsc3 -}

import qualified Language.Sc3.Lisp.Forth as Fs {- hsc3-lisp -}
import qualified Language.Sc3.Lisp.Haskell as Hs {- hsc3-lisp -}
import qualified Language.Sc3.Lisp.NameTable as Tbl {- hsc3-lisp -}
import qualified Language.Sc3.Lisp.Spl as Spl {- hsc3-lisp -}

optUsr :: [Opt.OptUsr]
optUsr =
  [ ("input-file", "/dev/stdin", "string", "haskell input file")
  , ("output-file", "/dev/stdout", "string", "scheme output file")
  , ("name-rewrite-table", "nil", "string", "name rewriting table")
  , ("mode", "module", "string", "parser mode, module|expression")
  ]

optHelp :: Opt.OptHelp
optHelp =
  [ "hsc3-sexp cmd [opt]"
  , "   haskell-to-lisp [opt]"
  , "   spl-to-forth [opt]"
  , "   supercollider-to-lisp [opt]"
  ]

sc_to_lisp_io :: Maybe FilePath -> FilePath -> FilePath -> IO ()
sc_to_lisp_io tbl_fn i_fn o_fn = do
  tbl <- maybe (return []) Tbl.nameTableLoad tbl_fn
  i <- readFile i_fn
  writeFile o_fn (Spl.toRenamedLispViewer False tbl Stc.stcParseToStc i)

main :: IO ()
main = do
  (opt, arg) <- Opt.opt_get_arg True optHelp optUsr
  let usage = Opt.opt_error optHelp optUsr
      mode x = case x of
        "expression" -> Hs.hs_exp_to_lisp
        "module" -> Hs.hs_to_lisp
        _ -> usage
      table x = if x == "nil" then Nothing else Just x
      translator = case arg of
        ["haskell-to-lisp"] -> Hs.hs_to_lisp_f_io
        ["supercollider-to-lisp"] -> \_ -> sc_to_lisp_io
        ["spl-to-forth"] -> \_ _ i o -> Io.interactWithFiles i o Fs.splToFs
        _ -> usage
  translator
    (mode (Opt.opt_get opt "mode"))
    (table (Opt.opt_get opt "name-rewrite-table"))
    (Opt.opt_get opt "input-file")
    (Opt.opt_get opt "output-file")
