use crate::api::models::*;

#[flutter_rust_bridge::frb(sync)]
pub fn get_channels(supplier: String) -> Vec<String> {
    match crate::suppliers::supplier(&supplier) {
        Some(sup) => sup.get_channels(),
        None => vec![]
    }
}

#[flutter_rust_bridge::frb(sync)]
pub fn get_default_channels(supplier: String) -> Vec<String> {
    match crate::suppliers::supplier(&supplier) {
        Some(sup) => sup.get_default_channels(),
        None => vec![]
    }
}

#[flutter_rust_bridge::frb(sync)]
pub fn get_supported_types(supplier: &String) -> Vec<ContentType> {
    match crate::suppliers::supplier(&supplier) {
        Some(sup) => sup.get_supported_types(),
        None => vec![]
    }
}

#[flutter_rust_bridge::frb(sync)]
pub fn get_supported_languages(supplier: &String) -> Vec<String> {
    match crate::suppliers::supplier(&supplier) {
        Some(sup) => sup.get_supported_languages(),
        None => vec![]
    }
}

pub fn search(supplier: String, query: String, types: Vec<String>) -> Vec<ContentInfo> {
    match crate::suppliers::supplier(&supplier) {
        Some(sup) => sup.search(query, types),
        None => vec![]
    }
}

pub fn load_channel(supplier: String, channel: String, page: u16) -> Vec<ContentInfo> {
    match crate::suppliers::supplier(&supplier) {
        Some(sup) => sup.load_channel(channel, page),
        None => vec![]
    }
}

pub fn get_content_details(supplier: String, id: String) -> Option<ContentDetails> {
    match crate::suppliers::supplier(&supplier) {
        Some(sup) => sup.get_content_details(id),
        None => Option::None
    }
}

pub fn load_media_items(supplier: String, id: String, params: Vec<String>) -> Vec<ContentMediaItem> {
    match crate::suppliers::supplier(&supplier) {
        Some(sup) => sup.load_media_items(id, params),
        None => vec![]
    }
}

pub fn load_media_item_sources(supplier: String, id: String, params: Vec<String>) -> Vec<ContentMediaItemSource> {
    match crate::suppliers::supplier(&supplier) {
        Some(sup) => sup.load_media_item_sources(id, params),
        None => vec![]
    }
}

#[flutter_rust_bridge::frb(sync)] // Synchronous mode for simplicity of the demo
pub fn avalaible_suppliers() -> Vec<String> {
    crate::suppliers::avalaible_suppliers()
}

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    // Default utilities - feel free to customize
    flutter_rust_bridge::setup_default_user_utils();
}
