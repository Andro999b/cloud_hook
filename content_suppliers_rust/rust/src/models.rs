use std::collections::HashMap;


#[derive(Debug)]
pub enum ContentType {
    Movie,
    Anime,
    Cartoon,
    Series,
    Manga,
}

#[derive(Debug)]
pub enum MediaType {
    Video,
    Manga,
}

#[derive(Debug)]
pub struct ContentInfo {
    pub id: String,
    pub supplier: String,
    pub title: String,
    pub secondary_title: Option<String>,
    pub image: String,
}

#[derive(Debug)]
pub struct ContentDetails {
    pub title: String,
    pub original_title: Option<String>,
    pub image: String,
    pub description: String,
    pub media_type: MediaType,
    pub additional_info: Vec<String>,
    pub similar: Vec<ContentInfo>,
    pub params: Vec<String>,
}

#[derive(Debug)]
pub struct ContentMediaItem {
    pub number: u32,
    pub title: String,
    pub section: Option<String>,
    pub image: Option<String>,
    pub sources: Option<Vec<ContentMediaItemSource>>,
    pub params: Vec<String>,
}

#[derive(Debug)]
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
        pages: Vec<String>,
    },
}