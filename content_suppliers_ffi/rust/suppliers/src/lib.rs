use std::{error::Error, future::Future, str::FromStr};

use models::{ContentDetails, ContentInfo, ContentMediaItem, ContentMediaItemSource, ContentType};
use strum::VariantNames;

pub mod dummy; 
pub mod models;

use dummy::DummyContentSupplier;
use enum_dispatch::enum_dispatch;
use strum_macros::{EnumIter, EnumString, VariantNames};

#[enum_dispatch(AllContentSuppliers)]
pub trait ContentSupplier {
    fn get_channels(&self) -> Vec<&str>;
    fn get_default_channels(&self) -> Vec<&str>;
    fn get_supported_types(&self) -> Vec<ContentType>;
    fn get_supported_languages(&self) -> Vec<&str>;
    fn load_channel(&self, channel: &str, page: u32) -> impl Future<Output = Result<Vec<ContentInfo>, Box<dyn Error>>> + Send;
    fn search(&self, query: &str, types: Vec<ContentType>) -> impl Future<Output = Result<Vec<ContentInfo>, Box<dyn Error>>> + Send;
    fn get_content_details(&self, id: &str) -> impl Future<Output = Result<Option<ContentDetails>, Box<dyn Error>>> + Send;
    fn load_media_items(&self, id: &str, params: Vec<String>) -> impl Future<Output = Result<Vec<ContentMediaItem>, Box<dyn Error>>> + Send;
    fn load_media_item_sources(&self, id: &str, params: Vec<String>) -> impl Future<Output = Result<Vec<ContentMediaItemSource>, Box<dyn Error>>> + Send;
}

#[enum_dispatch]
#[derive(EnumIter, EnumString, VariantNames)]
pub enum AllContentSuppliers {
    #[strum(serialize="dummy")]
    DummyContentSupplier
}

pub fn avalaible_suppliers() -> Vec<&'static str> {
    AllContentSuppliers::VARIANTS.to_vec()
}

pub fn get_supplier(name: &str) -> Result<AllContentSuppliers, Box<dyn Error>> {
    AllContentSuppliers::from_str(name).map_err(|err| err.into())
}

