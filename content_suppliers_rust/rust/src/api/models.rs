use std::collections::HashMap;

pub enum ContentType {
    Movie,
    Anime,
    Cartoon,
    Series,
    Manga,
}

pub enum MediaType {
    Video,
    Manga
}

pub struct ContentInfo {
    pub id: String,
    pub supplier: String,
    pub title: String,
    pub secondary_title: Option<String>,
    pub image: String,
}

pub struct ContentDetails {
    pub id: String,
    pub supplier: String,
    pub title: String,
    pub original_title: Option<String>,
    pub image: String,
    pub description: String,
    pub media_type: MediaType,
    pub additional_info: Vec<String>,
    pub similar: Vec<ContentInfo>,
    pub params: Vec<String>,
}

pub struct ContentMediaItem {
    pub number: u32,
    pub title: String,
    pub section: Option<String>,
    pub image: Option<String>,
    pub params: Vec<String>,
}

pub enum ContentMediaItemSource {
    Video {
        link: String,
        description: String,
        headers: HashMap<String, String>,
    },
    Subtitle {
        link: String,
        description: String,
        headers: HashMap<String, String>,
    },
    Manga {
        description: String,
        pages: Vec<String>
    },
}
