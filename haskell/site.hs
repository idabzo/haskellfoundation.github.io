{-# Language OverloadedStrings #-}
{-# Language TemplateHaskell #-}

import Control.Monad (when)
import Data.Monoid (mappend)
import Hakyll
import System.Directory
import System.Which
import System.FilePath.Posix (takeBaseName)

main :: IO ()
main = do
  do
    d <- getCurrentDirectory
    when (takeBaseName d == "haskell") $
      setCurrentDirectory "../site"
  hakyll $ do
    match "static/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "css/*" $ do
        route   idRoute
        compile postcss

    match (fromList ["about.rst", "contact.markdown"]) $ do
        route   $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/boilerplate.html" defaultContext
            >>= relativizeUrls

    -- match "posts/*" $ do
    --     route $ setExtension "html"
    --     compile $ pandocCompiler
    --         >>= loadAndApplyTemplate "templates/post.html"    postCtx
    --         >>= loadAndApplyTemplate "templates/default.html" postCtx
    --         >>= relativizeUrls

    -- create ["archive.html"] $ do
    --     route idRoute
    --     compile $ do
    --         posts <- recentFirst =<< loadAll "posts/*"
    --         let archiveCtx =
    --                 listField "posts" postCtx (return posts) `mappend`
    --                 constField "title" "Archives"            `mappend`
    --                 defaultContext

    --         makeItem ""
    --             >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
    --             >>= loadAndApplyTemplate "templates/default.html" archiveCtx
    --             >>= relativizeUrls


    match "index.html" $ do
        route idRoute
        compile $ do
            --posts <- recentFirst =<< loadAll "posts/*"
            let indexCtx =
            --        listField "posts" postCtx (return posts) `mappend`
                    constField "title" "Home"                `mappend`
                    defaultContext

            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/boilerplate.html" indexCtx
                >>= relativizeUrls

    match "templates/*" $ compile templateBodyCompiler


postCtx :: Context String
postCtx =
    dateField "date" "%B %e, %Y" `mappend`
    defaultContext

postcss :: Compiler (Item String)
postcss =
  getResourceString >>= withItemBody (unixFilter $(staticWhich "postcss") [])