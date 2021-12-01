{-# OPTIONS --guardedness --without-K #-}

module Day1 where

open import Data.Bool using (if_then_else_)
open import Data.Char as Char using (Char; isDigit; _≟_)
open import Data.Fin using (Fin; zero; suc; inject₁)
open import Data.Fin.Show using (show)
open import Data.List using (List; []; _∷_; map; linesBy)
open import Data.Nat using (ℕ; zero; suc; _+_; _∸_; _*_; _<?_)
open import Data.Nat.Properties using (+-suc)
import Data.String as String
open import Data.Unit.Polymorphic using (⊤)
open import Data.Vec as Vec using (Vec; []; _∷_; sum; take; tail)
open import IO using (IO; Main; run; _>>=_; _>>_; readFiniteFile; putStrLn)
open import Level using (0ℓ)
open import Relation.Nullary using (yes; no)

readℕ : ℕ → List Char → ℕ
readℕ n [] = n
readℕ n s@(c ∷ cs) =
  if isDigit c
  then readℕ (n * 10 + (Char.toℕ c ∸ Char.toℕ '0')) cs
  else n

increases : ∀ {n} → Vec ℕ (suc n) → Fin (suc n)
increases (x ∷ ys) with ys
... | [] = zero
... | y ∷ zs with x <? y
...   | yes _ = suc (increases ys)
...   | no _  = inject₁ (increases ys)

window : ∀ w {n} → Vec ℕ (w + n) → Vec ℕ n
window w {zero}  xs = []
window w {suc n} xs rewrite +-suc w n =
  (sum (take (suc w) xs)) ∷ window w (tail xs)

analyze : ∀ {n} → Vec ℕ n → IO {0ℓ} ⊤
analyze {suc (suc (suc n))} ds = do
  putStrLn (show (increases ds))
  putStrLn (show (increases (window 2 ds)))
analyze _ = putStrLn "not enough measurements"

main : Main
main = run do
  f <- readFiniteFile "day1.txt"
  let depths = map (readℕ zero) (linesBy (λ c → c ≟ '\n') (String.toList f))
  analyze (Vec.fromList depths)
