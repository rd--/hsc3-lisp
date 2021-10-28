import qualified Music.Theory.Opt as Opt {- hmt-base -}

import qualified Sound.SC3.Lisp.Haskell as Hs {- hsc3-lisp -}
import qualified Sound.SC3.Lisp.SuperCollider as Sc {- hsc3-lisp -}

opt :: [Opt.OptUsr]
opt =
  [("input-file","/dev/stdin","string","haskell input file")
  ,("output-file","/dev/stdout","string","scheme output file")
  ,("name-rewrite-table","nil","string","name rewriting table")
  ,("mode","module","string","parser mode, module|expression")]

help :: Opt.OptHelp
help =
  ["hsc3-sexp cmd [opt]"
  ,"   haskell-to-lisp [opt]"
  ,"   supercollider-to-lisp [opt]"]

main :: IO ()
main = do
  (o,a) <- Opt.opt_get_arg True help opt
  let usage = Opt.opt_error help opt
      mode x = case x of
                 "expression" -> Hs.hs_exp_to_lisp
                 "module" -> Hs.hs_to_lisp
                 _ -> usage
      table x = if x == "nil" then Nothing else Just x
      translator = case a of
        ["haskell-to-lisp"] -> Hs.hs_to_lisp_f_io
        ["supercollider-to-lisp"] -> \_ _ _ _ -> interact Sc.scToLispViewer
        _ -> usage
  translator
    (mode (Opt.opt_get o "mode"))
    (table (Opt.opt_get o "name-rewrite-table"))
    (Opt.opt_get o "input-file")
    (Opt.opt_get o "output-file")
