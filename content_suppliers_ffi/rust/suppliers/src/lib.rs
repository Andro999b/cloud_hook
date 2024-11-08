use std::{error::Error, future::Future, str::FromStr};

use models::{
    ContentDetails, 
    ContentInfo, 
    ContentMediaItem, 
    ContentMediaItemSource, 
    ContentSupplier,
    ContentType,
};
use strum::VariantNames;

pub mod dummy;
pub mod models;

use dummy::DummyContentSupplier;
use enum_dispatch::enum_dispatch;
use strum_macros::{EnumIter, EnumString, VariantNames};

#[enum_dispatch(ContentSupplier)]
#[derive(EnumIter, EnumString, VariantNames)]
pub enum AllContentSuppliers {
    #[strum(serialize = "dummy")]
    DummyContentSupplier,
}

pub fn avalaible_suppliers() -> Vec<&'static str> {
    AllContentSuppliers::VARIANTS.to_vec()
}

pub fn get_supplier(name: &str) -> Result<AllContentSuppliers, Box<dyn Error>> {
    AllContentSuppliers::from_str(name).map_err(|err| err.into())
}
