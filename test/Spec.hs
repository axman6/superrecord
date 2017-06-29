{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE OverloadedLabels #-}
{-# LANGUAGE DataKinds #-}
import SuperRecord

import Data.Aeson
import Test.Hspec

type Ex1 = '["foo" := String, "int" := Int]

r1 :: Rec Ex1
r1 =
    #foo := "Hi"
    & #int := 213
    & rnil

r2 :: Rec '["foo" := String]
r2 = #foo := "He" & rnil

polyFun :: Has "foo" lts idx String => Rec lts -> String
polyFun = get #foo

main :: IO ()
main = hspec $
    do it "getter works" $
           do get #foo r1 `shouldBe` "Hi"
              get #int r1 `shouldBe` 213
              polyFun r1 `shouldBe` "Hi"
              polyFun r2 `shouldBe` "He"
       it "setter works" $
           do let r1u = set #foo "Hey" r1
              get #foo r1 `shouldBe` "Hi"
              get #foo r1u `shouldBe` "Hey"
       it "getting record keys works" $
           do let vals = recKeys r1
              vals `shouldBe` ["foo", "int"]
       it "showRec words" $
           do let vals = showRec r1
              vals `shouldBe` [("foo", "\"Hi\""), ("int", "213")]
       it "show works" $
           show r1 `shouldBe` "[(\"foo\",\"\\\"Hi\\\"\"),(\"int\",\"213\")]"
       it "equality works" $
           do r1 == r1 `shouldBe` True
              r1 == set #foo "Hai" r1 `shouldBe` False
       it "toJSON matches fromJSON" $
           do decode (encode r1) `shouldBe` Just r1
              decode (encode r2) `shouldBe` Just r2
              decode "{\"foo\": true}" `shouldBe` Just (#foo := True & rnil)
