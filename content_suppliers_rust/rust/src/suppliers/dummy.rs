use std::collections::HashMap;

use crate::{
    api::models::{
        ContentDetails, 
        ContentInfo, 
        ContentMediaItem, 
        ContentMediaItemSource, 
        ContentType, MediaType,
    },
    suppliers::ContentSupplier,
};

static NAME: &str = "dummy";

pub struct DummyContentSupplier;

impl ContentSupplier for DummyContentSupplier {

    fn get_channels(&self) -> Vec<String> {
        vec![String::from("dummy_channels")]
    }

    fn get_default_channels(&self) -> Vec<String> {
        self.get_channels()
    }

    fn get_supported_types(&self) -> Vec<ContentType> {
        vec![ContentType::Movie, ContentType::Anime]
    }

    fn get_supported_languages(&self) -> Vec<String> {
        vec![String::from("en"), String::from("uk")]
    }

    fn search(&self, query: String, types: Vec<String>) -> Vec<ContentInfo> {
        vec![
            ContentInfo {
                id: query,
                supplier: String::from(NAME),
                title: types.join(","),
                secondary_title: Option::Some(String::from("secondary_dummy_title")),
                image: String::from("dummy_image")
            }
        ]
    }

    fn load_channel(&self, channel: String, page: u16) -> Vec<ContentInfo> {
        vec![
            ContentInfo {
                id: format!("{} {}", channel, page),
                supplier: String::from(NAME),
                title: String::from("dummy_title"),
                secondary_title: Option::Some(String::from("secondary_dummy_title")),
                image: String::from("dummy_image")
            }
        ]
    }

    fn get_content_details(&self, id: String) -> Option<ContentDetails> {
        Option::Some(
            ContentDetails { 
                id, 
                supplier: String::from(NAME), 
                title: String::from("dummy_title"),
                original_title: Option::Some(String::from("original_dummy_title")), 
                image: String::from("dummy_image"), 
                description: String::from("dummy_description"), 
                media_type: MediaType::Video, 
                additional_info: vec![
                    String::from("dummy_additional_info1"),
                    String::from("dummy_additional_info2"),
                ], 
                similar: vec![
                    ContentInfo {
                        id: String::from("dummy_similar"),
                        supplier: String::from(NAME),
                        title: String::from("dummy_title"),
                        secondary_title: Option::Some(String::from("secondary_dummy_title")),
                        image: String::from("dummy_image")
                    }
                ], 
                params: vec![String::from("1"), String::from("2")]
             }
        )
    }

    fn load_media_items(&self, id: String, params: Vec<String>) -> Vec<ContentMediaItem> {
        let mut new_params = params;
        new_params.push(String::from("3"));

        vec![
            ContentMediaItem {
                number: 42,
                title: id,
                section: Option::Some(new_params.join(",")),
                image: Option::Some(String::from("dummy_image")),
                params: new_params
            }
        ]
    }

    fn load_media_item_sources(
        &self,
        id: String,
        params: Vec<String>,
    ) -> Vec<ContentMediaItemSource> {
        vec![
            ContentMediaItemSource::Video {
                link: String::from("http://dummy_link"),
                description: format!("{} {}", id, params.join(",")),
                headers: HashMap::from([
                    (String::from("User-Agent"), String::from("dummy"))
                ])
            },
            ContentMediaItemSource::Subtitle {
                link: String::from("http://dummy_link"),
                description: format!("{} {}", id, params.join(",")),
                headers: HashMap::from([
                    (String::from("User-Agent"), String::from("dummy"))
                ])
            },
            ContentMediaItemSource::Manga { 
                description: format!("{} {}", id, params.join(",")), 
                pages: vec![
                    String::from("http://page1"),
                    String::from("http://page2"),
                ] 
            }
        ]
    }
}
