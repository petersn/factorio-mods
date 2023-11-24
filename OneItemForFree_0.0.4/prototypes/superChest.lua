local superChestEntity = table.deepcopy(data.raw.container["steel-chest"])
superChestEntity.type = "infinity-container"
superChestEntity.name = "super-chest"
superChestEntity.picture.layers[1].tint = {1,0.4,0.4,1.0}
superChestEntity.minable.result = "super-chest"
superChestEntity.gui_mode = "none"
superChestEntity.erase_contents_when_mined = true

local superChestItem = table.deepcopy(data.raw.item["steel-chest"])
superChestItem.name = "super-chest"
superChestItem.subgroup = "storage"
superChestItem.order = "a[items]-b[super-chest]"
superChestItem.place_result = "super-chest"
superChestItem.icons = {
    {
        icon=superChestItem.icon,
        tint={1,0.4,0.4,1.0}
    }
}

data:extend{superChestEntity, superChestItem}
