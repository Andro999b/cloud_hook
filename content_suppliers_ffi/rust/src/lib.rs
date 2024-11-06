use std::error::Error;

use suppliers::{dummy::DummyContentSupplier, ContentSupplier};

mod schema_generated;
mod suppliers;
mod wire;

pub fn avalaible_suppliers() -> Vec<&'static str> {
    vec!["dummy"]
}

pub fn get_supplier(name: &str) -> Result<&dyn ContentSupplier, Box<dyn Error>> {
    return match name {
        "dummy" => Ok(&DummyContentSupplier {}),
        _ => Err(format!("Supplier {} not found", name).into())
    }
}

