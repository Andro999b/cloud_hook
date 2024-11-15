# ##############################################################################
# # GENERAL
# ##############################################################################

.PHONY: help
help: makefile
	@echo
	@echo " Available actions in "$(PROJECTNAME)":"
	@echo
	@sed -n 's/^##//p' $< | column -t -s ':' |  sed -e 's/^/ /'
	@echo

## generate flatbuffer shcemas
.PHONY: schemas
schemas: schema-dart schema-rust

## generate flatbuffer shcema for dart
.PHONY: schema-dart
schema-dart: 
	flatc --dart --gen-object-api -o lib/internal schema.fbs

## generate flatbuffer shcema for rust
.PHONY: schema-rust
schema-rust: 
	flatc --rust -o rust/src schema.fbs
