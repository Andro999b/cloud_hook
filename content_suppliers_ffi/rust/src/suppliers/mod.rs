pub mod dummy; 
pub mod models;

use std::error::Error;

use crate::suppliers::models::{
    ContentDetails, 
    ContentInfo, 
    ContentMediaItem, 
    ContentMediaItemSource, 
    ContentType,
};

pub trait ContentSupplier {
    fn get_channels(&self) -> Vec<&str>;
    fn get_default_channels(&self) -> Vec<&str>;
    fn get_supported_types(&self) -> Vec<ContentType>;
    fn get_supported_languages(&self) -> Vec<&str>;
    fn load_channel(&self, channel: &str, page: u32) -> Result<Vec<ContentInfo>, Box<dyn Error>>;
    fn search(&self, query: &str, types: Vec<ContentType>) -> Result<Vec<ContentInfo>, Box<dyn Error>>;
    fn get_content_details(&self, id: &str) -> Result<Option<ContentDetails>, Box<dyn Error>>;
    fn load_media_items(&self, id: &str, params: Vec<String>) -> Result<Vec<ContentMediaItem>, Box<dyn Error>>;
    fn load_media_item_sources(&self, id: &str, params: Vec<String>) -> Result<Vec<ContentMediaItemSource>, Box<dyn Error>>;
}
