use crate::api::models::{*};

pub struct Bridge {
    pub name: String,
}

impl ContentSupplier for Bridge {
    #[flutter_rust_bridge::frb(sync)]
    fn get_name(&self) -> String {
        String::from(&self.name)
    }
    #[flutter_rust_bridge::frb(sync)]
    fn get_channels(&self) -> Vec<String> {
        vec![]
    }
    #[flutter_rust_bridge::frb(sync)]
    fn get_default_channels(&self) -> Vec<String> {
        vec![]
    }
    #[flutter_rust_bridge::frb(sync)]
    fn get_supported_types(&self) -> Vec<ContentType> {
        vec![]
    }
    #[flutter_rust_bridge::frb(sync)]
    fn get_supported_languages(&self) -> Vec<String> {
        vec![]
    }
    fn search(&self, query: &String, types: &Vec<String>) -> Vec<ContentInfo> {
        vec![]
    }
    fn load_channel(&self, channel: &String, page: u16) -> Vec<ContentInfo> {
        vec![]
    }
    fn get_content_details(&self, id: &String) -> Option<ContentDetails> {
        Option::None
    }
    fn load_media_items(&self, id: &String, params: &Vec<String>) -> Vec<ContentMediaItem> {
        vec![]
    }
    fn load_media_item_sources(&self, id: &String, params: &Vec<String>) -> Vec<ContentMediaItemSource> {
        vec![]
    }
}

#[flutter_rust_bridge::frb(sync)] // Synchronous mode for simplicity of the demo
pub fn avalaible_suppliers() -> Vec<String> {
    vec![String::from("dummy")]
}

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    // Default utilities - feel free to customize
    flutter_rust_bridge::setup_default_user_utils();
}