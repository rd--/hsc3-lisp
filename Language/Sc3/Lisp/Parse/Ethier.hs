-- | SExp parser using husk-scheme <https://github.com/justinethier/husk-scheme> (Ethier)
module Language.Sc3.Lisp.Parse.Ethier where

import qualified Numeric {- base -}

import qualified Control.Monad.Except as E {- mtl -}
import qualified Data.ByteString as B {- bytestring -}

import qualified Language.Scheme.Parser as S {- husk-scheme -}
import qualified Language.Scheme.Types as S {- husk-scheme -}

import qualified Language.Sc3.Lisp.Type as L {- hsc3-lisp -}

-- | S-expression
type SExp = S.LispVal

{-
import Text.Printf {- base -}
let fn = "/home/rohan/sw/rsc3/help/graph/jmcc-bowed-string.scm"
txt <- readFile fn
S.readExprList (printf "(show-graph %s)" txt)
-}

parse_sexp_vm :: String -> L.EnvMonad IO String (L.Expr a) [SExp]
parse_sexp_vm = either (E.throwError . show) return . S.readExprList

sexp_to_exp :: L.Lisp_Ty a => SExp -> L.EnvMonad IO String (L.Expr a) (L.Expr a)
sexp_to_exp sexp =
  case sexp of
    S.Number n -> return (L.Atom (fromIntegral n))
    S.Float n -> return (L.Atom (realToFrac n))
    S.Rational n -> return (L.Atom (fromRational n))
    S.Atom nm -> return (L.Symbol nm)
    S.String s -> return (L.String s)
    S.Bool b -> return (L.Atom (L.ty_from_bool b))
    S.List [] -> return L.Nil
    S.List (e : l) -> sexp_to_exp e >>= \e' -> fmap (L.Cons e') (sexp_to_exp (S.List l))
    _ -> E.throwError ("sexp-to-exp: " ++ show sexp)

{- | The husk-scheme printer uses "show" for Floats,
     prints 'Char' directly,
     and uses literal syntax for bytevectors.

>>> (S.Float 0.01,S.Char 'c',S.ByteVector (B.pack [0,1,2]))
(1.0e-2,c,#u8(0 1 2))

>>> mapM_ (putStrLn . sexp_show) [S.Float 0.01,S.Char 'c',S.ByteVector (B.pack [0,1,2])]
0.01
#\c
(bytevector 0 1 2)
-}
sexp_show :: SExp -> String
sexp_show s =
  case s of
    S.Atom x -> x
    S.Char x -> ['#', '\\', x]
    S.Float x -> Numeric.showFFloat Nothing x ""
    S.List x -> "(" ++ unwords (map sexp_show x) ++ ")"
    S.DottedList x y -> concat ["(", unwords (map sexp_show x), " . ", sexp_show y, ")"]
    S.Number x -> show x
    S.String x -> "\"" ++ x ++ "\""
    S.Vector _ -> show s
    S.ByteVector x -> "(bytevector " ++ unwords (map show (B.unpack x)) ++ ")"
    _ -> error ("sexp_show: " ++ show s)
