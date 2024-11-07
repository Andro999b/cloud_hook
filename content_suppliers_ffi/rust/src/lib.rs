use std::{error::Error, str::FromStr};

use strum::VariantNames;
use suppliers::AllContentSuppliers;

mod schema_generated;
mod suppliers;
mod wire;


pub fn avalaible_suppliers() -> Vec<&'static str> {
    AllContentSuppliers::VARIANTS.to_vec()
}

pub fn get_supplier(name: &str) -> Result<AllContentSuppliers, Box<dyn Error>> {
    AllContentSuppliers::from_str(name).map_err(|err| err.into())
}

