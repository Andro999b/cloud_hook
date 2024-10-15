pub mod dummy; 

use dummy::DummyContentSupplier;

use crate::api::models::{
    ContentDetails, 
    ContentInfo, 
    ContentMediaItem, 
    ContentMediaItemSource, 
    ContentType,
};

pub trait ContentSupplier {
    fn get_channels(&self) -> Vec<String>;
    fn get_default_channels(&self) -> Vec<String>;
    fn get_supported_types(&self) -> Vec<ContentType>;
    fn get_supported_languages(&self) -> Vec<String>;
    fn search(&self, query: String, types: Vec<String>) -> Vec<ContentInfo>;
    fn load_channel(&self, channel: String, page: u16) -> Vec<ContentInfo>;
    fn get_content_details(&self, id: String) -> Option<ContentDetails>;
    fn load_media_items(&self, id: String, params: Vec<String>) -> Vec<ContentMediaItem>;
    fn load_media_item_sources(&self, id: String, params: Vec<String>) -> Vec<ContentMediaItemSource>;
}

pub fn avalaible_suppliers() -> Vec<String> {
    vec![String::from("dummy")]
}

pub fn supplier(name: &str) -> Option<&dyn ContentSupplier> {
    return match name {
        "dummy" => Option::Some(&DummyContentSupplier {}),
        _ => Option::None
    }
}
