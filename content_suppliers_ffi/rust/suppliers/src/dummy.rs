use std::{collections::HashMap, error::Error};

use crate::{models::{ContentDetails, ContentInfo, ContentMediaItem, ContentMediaItemSource, ContentType, MediaType}, ContentSupplier};

static NAME: &str = "dummy";

pub struct DummyContentSupplier;

impl Default for DummyContentSupplier {
    fn default() -> Self {
        Self {}
    }
}

impl ContentSupplier for DummyContentSupplier {

    fn get_channels(&self) -> Vec<&str> {
        vec!["dummy_channel"]
    }

    fn get_default_channels(&self) -> Vec<&str> {
        self.get_channels()
    }

    fn get_supported_types(&self) -> Vec<ContentType> {
        vec![ContentType::Movie, ContentType::Anime]
    }

    fn get_supported_languages(&self) -> Vec<&str> {
        vec!["en", "uk"]
    }

    async fn load_channel(&self, channel: &str, page: u32) -> Result<Vec<ContentInfo>, Box<dyn Error>> {
        if !self.get_channels().contains(&channel) {
            return Err("Unknow channel".into());
        }

        Ok(vec![
            ContentInfo {
                id: format!("{} {}", channel, page),
                supplier: NAME.to_owned(),
                title: "dummy_title".to_owned(),
                secondary_title: Some("secondary_dummy_title".to_owned()),
                image: "dummy_image".to_owned()
            }
        ])
    }

    async fn search(&self, query: &str, types: Vec<ContentType>) -> Result<Vec<ContentInfo>, Box<dyn Error>> {
        Ok(vec![
            ContentInfo {
                id: query.to_owned(),
                supplier: NAME.to_owned(),
                title: types.iter().map(|&t| (t as i8).to_string()).collect::<Vec<_>>().join(","),
                secondary_title: Some("secondary_dummy_title".to_owned()),
                image: "dummy_image".to_owned()
            }
        ])
    }

    async fn get_content_details(&self, id: &str) -> Result<Option<ContentDetails>, Box<dyn Error>> {
        Ok(Some(
            ContentDetails { 
                id: id.into(), 
                supplier: NAME.to_owned(), 
                title: "dummy_title".to_owned(),
                original_title: Some("original_dummy_title".to_owned()), 
                image: "dummy_image".to_owned(), 
                description: "dummy_description".to_owned(), 
                media_type: MediaType::Video, 
                additional_info: vec![
                    "dummy_additional_info1".to_owned(),
                    "dummy_additional_info2".to_owned(),
                ], 
                similar: vec![
                    ContentInfo {
                        id: "dummy_similar".to_owned(),
                        supplier: NAME.to_owned(),
                        title: "dummy_title".to_owned(),
                        secondary_title: Some("secondary_dummy_title".to_owned()),
                        image: "dummy_image".to_owned()
                    }
                ], 
                params: vec!["1".to_owned(), "2".to_owned()]
             }
        ))
    }

    async fn load_media_items(&self, id: &str, params: Vec<String>) -> Result<Vec<ContentMediaItem>, Box<dyn Error>>  {
        let mut new_params = params;

        new_params.push("3".to_owned());

        Ok(vec![
            ContentMediaItem {
                number: 42,
                title: id.into(),
                section: Some(new_params.join(",")),
                image: Some("dummy_image".to_owned()),
                params: new_params
            }
        ])
    }

    async fn load_media_item_sources(
        &self,
        id: &str,
        params: Vec<String>,
    ) -> Result<Vec<ContentMediaItemSource>, Box<dyn Error>> {
        Ok(vec![
            ContentMediaItemSource::Video {
                link: "http://dummy_link".to_owned(),
                description: format!("{} {}", id, params.join(",")),
                headers: HashMap::from([
                    ("User-Agent".to_owned(), "dummy".to_owned())
                ])
            },
            ContentMediaItemSource::Subtitle {
                link: "http://dummy_link".to_owned(),
                description: format!("{} {}", id, params.join(",")),
                headers: HashMap::from([
                    ("User-Agent".to_owned(), "dummy".to_owned())
                ])
            },
            ContentMediaItemSource::Manga { 
                description: format!("{} {}", id, params.join(",")), 
                pages: vec![
                    "http://page1".to_owned(),
                    "http://page2".to_owned(),
                ] 
            }
        ])
    }
}
