local superChestEntity = table.deepcopy(data.raw.container["steel-chest"])
superChestEntity.name = "super-chest"
superChestEntity.picture.layers[1].tint = {r=1,g=0.4,b=0.4,a=1.0}
superChestEntity.minable.result = "super-chest"


local superChestItem = table.deepcopy(data.raw.item["steel-chest"])
superChestItem.name = "super-chest"
superChestItem.subgroup = "storage"
superChestItem.order = "a[items]-b[super-chest]"
superChestItem.place_result = "super-chest"
superChestItem.icons = {
    {
        icon=superChestItem.icon,
        tint={r=1,g=0.4,b=0.4,a=1.0}
    }
}

data:extend{superChestEntity, superChestItem}
