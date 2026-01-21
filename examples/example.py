from pysomr import (
    OW,
    OW_SETTINGS_KEY_BOY_CLASS,
    OW_SETTINGS_KEY_GIRL_CLASS,
    OW_SETTINGS_KEY_SPRITE_CLASS,
    WORKING_DATA_KEY_BOY_CLASS,
    WORKING_DATA_KEY_GIRL_CLASS,
    WORKING_DATA_KEY_SPRITE_CLASS,
    WORKING_DATA_KEY_BOY_EXISTS,
    WORKING_DATA_KEY_GIRL_EXISTS,
    WORKING_DATA_KEY_SPRITE_EXISTS,
    WORKING_DATA_KEY_BOY_IN_LOGIC,
    WORKING_DATA_KEY_GIRL_IN_LOGIC,
    WORKING_DATA_KEY_SPRITE_IN_LOGIC,
    WORKING_DATA_KEY_BOY_START_WEAPON_INDEX,
    WORKING_DATA_KEY_GIRL_START_WEAPON_INDEX,
    WORKING_DATA_KEY_SPRITE_START_WEAPON_INDEX,
)


def test() -> None:
    for item in OW.get_all_items():
        print(f"{item.id} ({item.event_flag}): {item.name}")
    for location in OW.get_all_locations():
        print(f"{location.id}: {location.name}")
    ow = OW(
        "path/to/som.smc",
        "1",
        {
            # no magic:
            OW_SETTINGS_KEY_BOY_CLASS: "OGboy",
            OW_SETTINGS_KEY_GIRL_CLASS: "OGboy",
            OW_SETTINGS_KEY_SPRITE_CLASS: "OGboy",
        },
    )
    for location in ow.generator.get_locations():
        print(f"{location.id}: {location.name}: " + ", ".join(location.requirements))
    for item in ow.generator.get_items():
        print(f"{item.id}: {item.name}: {item.type}")

    boy_class = ow.context.working_data[WORKING_DATA_KEY_BOY_CLASS]
    girl_class = ow.context.working_data[WORKING_DATA_KEY_GIRL_CLASS]
    sprite_class = ow.context.working_data[WORKING_DATA_KEY_SPRITE_CLASS]
    boy_exists = ow.context.working_data.get_bool(WORKING_DATA_KEY_BOY_EXISTS)
    girl_exists = ow.context.working_data.get_bool(WORKING_DATA_KEY_GIRL_EXISTS)
    sprite_exists = ow.context.working_data.get_bool(WORKING_DATA_KEY_SPRITE_EXISTS)
    boy_in_logic = ow.context.working_data.get_bool(WORKING_DATA_KEY_BOY_IN_LOGIC)
    girl_in_logic = ow.context.working_data.get_bool(WORKING_DATA_KEY_GIRL_IN_LOGIC)
    sprite_in_logic = ow.context.working_data.get_bool(WORKING_DATA_KEY_SPRITE_IN_LOGIC)
    boy_start_weapon = ow.context.working_data.get_int(WORKING_DATA_KEY_BOY_START_WEAPON_INDEX)
    girl_start_weapon = ow.context.working_data.get_int(WORKING_DATA_KEY_GIRL_START_WEAPON_INDEX)
    sprite_start_weapon = ow.context.working_data.get_int(WORKING_DATA_KEY_SPRITE_START_WEAPON_INDEX)

    print(f"boy role:        {boy_class}")
    print(f"girl role:       {girl_class}")
    print(f"sprite role:     {sprite_class}")
    print(f"boy exists:      {boy_exists}")
    print(f"girl exists:     {girl_exists}")
    print(f"sprite exists:   {sprite_exists}")
    print(f"boy in logic:    {boy_in_logic}")
    print(f"girl in logic:   {girl_in_logic}")
    print(f"sprite in logic: {sprite_in_logic}")
    print(f"boy weapon:      {boy_start_weapon}")
    print(f"girl weapon:     {girl_start_weapon}")
    print(f"sprite weapon:   {sprite_start_weapon}")

    ow.run("path/to/somr.smc")


if __name__ == "__main__":
    test()
