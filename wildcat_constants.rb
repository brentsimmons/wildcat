ENV_KEY_WEBSITES_FOLDER = 'WILDCAT_WEBSITES_FOLDER'.freeze
ENV_KEY_USERNAME = 'WILDCAT_USERNAME'.freeze
ENV_KEY_HASHED_PASSWORD = 'WILDCAT_HASHED_PASSWORD'.freeze
ENV_KEY_RUNNING_AS_SERVER = 'WILDCAT_RUNNING_AS_SERVER'.freeze

MARKDOWN_SUFFIX = '.markdown'.freeze
HTML_SUFFIX = '.html'.freeze
MARKDOWN_NO_LEADING_DOT = 'markdown'.freeze
HTML_NO_LEADING_DOT = 'html'.freeze

# These appear inside source files, at the top.

TITLE_KEY = 'title'.freeze
LINK_KEY = 'link'.freeze
PUB_DATE_KEY = 'pubDate'.freeze
MOD_DATE_KEY = 'modDate'.freeze
ENCLOSURE_URL_KEY = 'enclosure'.freeze
ENCLOSURE_TYPE_KEY = 'enclosureType'.freeze
ENCLOSURE_LENGTH_KEY = 'enclosureLength'.freeze
ITUNES_DURATION_KEY = 'itunesDuration'.freeze
ITUNES_SUBTITLE_KEY = 'itunesItemSubtitle'.freeze
ITUNES_SUMMARY_KEY = 'itunesItemSummary'.freeze
ITUNES_EXPLICIT_KEY = 'itunesExplicit'.freeze
MEDIA_THUMBNAIL_KEY = 'mediaThumbnail'.freeze

# These appear in context tables when rendering.

CONTEXT_PERMALINK_KEY = 'permalink'.freeze
CONTEXT_EXTERNAL_URL_KEY = 'external_url'.freeze
CONTEXT_LINK_PREFERRING_EXTERNAL_URL_KEY = 'link_preferring_external_url'.freeze # Use external_url when present, falling back to permalink.
CONTEXT_TITLE_KEY = 'title'.freeze
CONTEXT_CONTENT_HTML_KEY = 'content_html'.freeze
CONTEXT_PUB_DATE_KEY = 'pub_date'.freeze
CONTEXT_DISPLAY_DATE_KEY = 'display_date'.freeze

# JSON Feed generation

JSON_FEED_URL_KEY = 'url'.freeze
JSON_FEED_EXTERNAL_URL_KEY = 'external_url'.freeze
JSON_FEED_ID_KEY = 'id'.freeze
JSON_FEED_TITLE_KEY = 'title'.freeze
JSON_FEED_CONTENT_HTML_KEY = 'content_html'.freeze
JSON_FEED_PUB_DATE_KEY = 'date_published'.freeze
JSON_FEED_ATTACHMENTS_KEY = 'attachments'.freeze
JSON_FEED_ENCLOSURE_URL = 'url'.freeze
JSON_FEED_ENCLOSURE_MIME_TYPE = 'mime_type'.freeze
JSON_FEED_ENCLOSURE_SIZE_IN_BYTES = 'size_in_bytes'.freeze
