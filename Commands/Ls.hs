{-
Copyright (C) 2006-2008 John Goerzen <jgoerzen@complete.org>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
-}

module Commands.Ls(lsrecent, lsfollowing) where
import Utils
import System.Log.Logger
import Types
import Text.Printf
import System.Console.GetOpt
import Data.List
import Text.XML.HaXml
import Download
import FeedParser

i = infoM "ls"

--------------------------------------------------
-- lsrecent
--------------------------------------------------

lsrecent = simpleCmd "lsrecent" "List recent updates from those you follow"
             lsrecent_help
             [] lsrecent_worker

lsrecent_worker _ cp _ =
    do xmlstr <- sendAuthRequest cp "/statuses/friends_timeline.xml" [] []
       debugM "lsrecent" $ "Got doc: " ++ xmlstr
       let doc = getContent . xmlParse "lsrecent" . stripUnicodeBOM $ xmlstr
       mapM_ printStatus . map procStatuses . getStatuses $ doc
       
    where

          getStatuses = tag "statuses" /> tag "status"
          printStatus (name, text) =
              printf "<%s> %s\n" name text

lsrecent_help =
 "Usage: twidge lsrecent\n\n"

procStatuses :: Content -> (String, String)
procStatuses item = 
    (sanitize $ contentToString 
      (keep /> tag "user" /> tag "screen_name" /> txt $ item),
     sanitize $ contentToString
     (keep /> tag "text" /> txt $ item)
    )

--------------------------------------------------
-- lsfollowing
--------------------------------------------------

lsfollowing = simpleCmd "lsfollowing" "List people you are following"
             lsfollowing_help
             [] lsfollowing_worker

lsfollowing_worker _ cp (_, user) =
    do xmlstr <- sendAuthRequest cp "/statuses/friends_timeline.xml" [] []
       debugM "lsfollowing" $ "Got doc: " ++ xmlstr
       return ()
       -- let doc = getContent . xmlParse "lsfollowing" . stripUnicodeBOM $ xmlstr
       -- mapM_ printStatus . map procStatuses . getStatuses $ doc
       
    where url = case user of
                  [] -> "/statuses/friends.xml"
                  [x] -> "/statuses/friends/" ++ x ++ ".xml"
                  _ -> error "Invalid args to lsfollowing; see twidge lsfollowing --help"
          getStatuses = tag "statuses" /> tag "status"
          printStatus (name, text) =
              printf "<%s> %s\n" name text

lsfollowing_help =
 "Usage: twidge lsfollowing [username]\n\n\
 \If username is given, list the twitter accounts that user is following.\n\
 \Otherwise, list the twitter accounts your user is following.\n"
