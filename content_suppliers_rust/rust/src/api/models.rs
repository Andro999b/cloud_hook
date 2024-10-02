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
    pub number: u16,
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

pub trait ContentSupplier {
    #[flutter_rust_bridge::frb(ignore)]
    fn get_name(&self) -> String;
    #[flutter_rust_bridge::frb(ignore)]
    fn get_channels(&self) -> Vec<String>;
    #[flutter_rust_bridge::frb(ignore)]
    fn get_default_channels(&self) -> Vec<String>;
    #[flutter_rust_bridge::frb(ignore)]
    fn get_supported_types(&self) -> Vec<ContentType>;
    #[flutter_rust_bridge::frb(ignore)]
    fn get_supported_languages(&self) -> Vec<String>;
    #[flutter_rust_bridge::frb(ignore)]
    fn search(&self, query: &String, types: &Vec<String>) -> Vec<ContentInfo>;
    #[flutter_rust_bridge::frb(ignore)]
    fn load_channel(&self, channel: &String, page: u16) -> Vec<ContentInfo>;
    #[flutter_rust_bridge::frb(ignore)]
    fn get_content_details(&self, id: &String) -> Option<ContentDetails>;
    #[flutter_rust_bridge::frb(ignore)]
    fn load_media_items(&self, id: &String, params: &Vec<String>) -> Vec<ContentMediaItem>;
    #[flutter_rust_bridge::frb(ignore)]
    fn load_media_item_sources(&self, id: &String, params: &Vec<String>) -> Vec<ContentMediaItemSource>;
}
