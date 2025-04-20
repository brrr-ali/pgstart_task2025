CREATE TABLE IF NOT EXISTS "Users"
(
    "Id"             INT PRIMARY KEY,
    "Reputation"     INT,
    "CreationDate"   TIMESTAMP,
    "DisplayName"    text,
    "LastAccessDate" TIMESTAMP,
    "WebsiteUrl"     text,
    "Location"       text,
    "AboutMe"        TEXT,
    "Views"          INT,
    "UpVotes"        INT,
    "DownVotes"      INT,
    "AccountId"      INT
);


CREATE TABLE IF NOT EXISTS "Badges"
(
    "Id"       INT PRIMARY KEY,
    "UserId"   INT REFERENCES "Users" ("Id"),
    "Name"     text,
    "Date"     TIMESTAMP,
    "Class"    int,
    "TagBased" boolean
);

CREATE TABLE IF NOT EXISTS "PostTypes"
(
    "Id"   INT PRIMARY KEY,
    "Name" text
);

CREATE TABLE IF NOT EXISTS "Posts"
(
    "Id"                    INT PRIMARY KEY,
    "AcceptedAnswerId"      INT REFERENCES "Posts" ("Id"),
    "AnswerCount"           INT,
    "Body"                  text,
    "ClosedDate"            TIMESTAMP,
    "CommentCount"          INT,
    "CommunityOwnedDate"    TIMESTAMP,
    "ContentLicense"        text,
    "CreationDate"          TIMESTAMP,
    "FavoriteCount"         INT,
    "LastActivityDate"      TIMESTAMP,
    "LastEditDate"          TIMESTAMP,
    "LastEditorDisplayName" text,
    "LastEditorUserId"      INT REFERENCES "Users" ("Id"),
    "OwnerDisplayName"      text,
    "OwnerUserId"           INT REFERENCES "Users" ("Id"),
    "ParentId"              INT REFERENCES "Posts" ("Id"),
    "PostTypeId"            INT REFERENCES "PostTypes" ("Id"),
    "Score"                 INT,
    "Tags"                  text,
    "Title"                 TEXT,
    "ViewCount"             INT
);

CREATE TABLE IF NOT EXISTS "PostHistoryTypes"
(
    "Id"   INT PRIMARY KEY,
    "Name" text
);

CREATE TABLE IF NOT EXISTS "Comments"
(
    "Id"              INT PRIMARY KEY,
    "CreationDate"    TIMESTAMP,
    "PostId"          INT REFERENCES "Posts" ("Id"),
    "Score"           INT,
    "Text"            text,
    "UserDisplayName" text,
    "UserId"          INT REFERENCES "Users" ("Id")
)
;

CREATE TABLE IF NOT EXISTS "PostHistory"
(
    "Id"                INT PRIMARY KEY,
    "Comment"           text,
    "ContentLicense"    text,
    "CreationDate"      TIMESTAMP,
    "PostHistoryTypeId" INT REFERENCES "PostHistoryTypes" ("Id"),
    "PostId"            INT REFERENCES "Posts" ("Id"),
    "RevisionGUID"      text,
    "Text"              text,
    "UserDisplayName"   text,
    "UserId"            INT REFERENCES "Users" ("Id")
);
CREATE TABLE IF NOT EXISTS "Tags"
(
    "Id"              INT PRIMARY KEY,
    "Count"           INT,
    "ExcerptPostId"   INT REFERENCES "Posts" ("Id"),
    "IsModeratorOnly" boolean,
    "TagName"         text,
    "WikiPostId"      INT REFERENCES "Posts" ("Id"),
    "IsRequired"      boolean
)
;



CREATE TABLE IF NOT EXISTS "VoteTypes"
(
    "Id"   INT PRIMARY KEY,
    "Name" text
);

CREATE TABLE IF NOT EXISTS "Votes"
(
    "Id"           INT PRIMARY KEY,
    "CreationDate" TIMESTAMP,
    "PostId"       INT REFERENCES "Posts" ("Id"),
    "VoteTypeId"   INT REFERENCES "VoteTypes" ("Id")
);
ALTER TABLE "Votes" ADD "BountyAmount" INT;
ALTER TABLE "Votes" ADD "UserId" INT REFERENCES "Users"("Id");


CREATE TABLE IF NOT EXISTS "PostLinks"
(
    "Id"            INT PRIMARY KEY,
    "CreationDate"  TIMESTAMP,
    "PostId"        INT REFERENCES "Posts" ("Id"),
    "RelatedPostId" INT REFERENCES "Posts" ("Id"),
    "LinkTypeId"    INT /*1 = Linked (PostId contains a link to RelatedPostId)
3 = Duplicate (PostId is a duplicate of RelatedPostId)*/

);
