# pysomr - Python Wrapper for SoMR API
# Copyright (C) 2026  black-sliver
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.

#cython: language_level=3
#distutils: language = c
#distutils: depends = SecretOfManaRandomizer/SoMRandomizer.api/c/api.h

# NOTE: cython support in IDEs is not great, specifically tracking cdef types,
#       so we add a bunch of "no inspection" markers everywhere

import pathlib
import typing as t

import cython
from libc.stdint cimport uint_least16_t, int32_t, uint8_t


ctypedef uint_least16_t char16_t
"""Strings are "windows wide char*" that is pointers to 16bit characters encoded in "windows unicode" (UCS2/WTF16)"""


cdef extern from *:
    """
    // avoid warning from cython-generated code with MSVC + pyximport
    #ifdef _MSC_VER
    #pragma warning( disable: 4551 )
    #endif
    """


cdef extern from "SecretOfManaRandomizer/SoMRandomizer.api/c/api.h":
    ctypedef struct SoMR_ItemList:
        pass
    ctypedef struct SoMR_Item:
        pass
    ctypedef struct SoMR_LocationList:
        pass
    ctypedef struct SoMR_Location:
        pass
    ctypedef struct SoMR_OWSettings:
        pass
    ctypedef struct SoMR_OWGenerator:
        pass
    ctypedef struct SoMR_Context:
        pass
    ctypedef struct SoMR_WorkingData:
        pass
    ctypedef struct SoMR_StrList:
        pass

    # noinspection PyPep8Naming
    SoMR_ItemList* SoMR_OW_GetAllItems()
    # noinspection PyPep8Naming
    SoMR_LocationList* SoMR_OW_GetAllLocations()
    # noinspection PyPep8Naming
    SoMR_OWSettings* SoMR_OW_NewSettings()
    # noinspection PyPep8Naming
    SoMR_OWGenerator* SoMR_OW_NewGenerator()
    # noinspection PyPep8Naming
    SoMR_Context* SoMR_OW_Init(char16_t* src, char16_t* seed, SoMR_OWGenerator* generator, SoMR_OWSettings* settings)
    # noinspection PyPep8Naming
    void SoMR_OW_Run(
            char16_t* src,
            char16_t* seed,
            SoMR_OWGenerator* generator,
            SoMR_OWSettings* settings,
            SoMR_Context* context,
    )

    # noinspection PyPep8Naming
    int32_t SoMR_ItemList_Count(SoMR_ItemList* lst)
    # noinspection PyPep8Naming
    SoMR_Item* SoMR_ItemList_At(SoMR_ItemList* lst, int32_t index)
    # noinspection PyPep8Naming
    void SoMR_ItemList_Unref(SoMR_ItemList* lst)
    # noinspection PyPep8Naming
    char16_t* SoMR_Item_GetName(SoMR_Item* item)
    # noinspection PyPep8Naming
    char16_t * SoMR_Item_GetType(SoMR_Item* item)
    # noinspection PyPep8Naming
    uint8_t SoMR_Item_GetEventFlag(SoMR_Item* item)
    # noinspection PyPep8Naming
    uint8_t SoMR_Item_GetItemId(SoMR_Item* item)
    # noinspection PyPep8Naming
    void SoMR_Item_Unref(SoMR_Item* item)

    # noinspection PyPep8Naming
    int32_t SoMR_LocationList_Count(SoMR_LocationList* lst)
    # noinspection PyPep8Naming
    SoMR_Location* SoMR_LocationList_At(SoMR_LocationList* lst, int32_t index)
    # noinspection PyPep8Naming
    void SoMR_LocationList_Unref(SoMR_LocationList* lst)
    # noinspection PyPep8Naming
    char16_t* SoMR_Location_GetName(SoMR_Location* location)
    # noinspection PyPep8Naming
    int32_t SoMR_Location_GetMapNum(SoMR_Location * location)
    # noinspection PyPep8Naming
    int32_t SoMR_Location_GetObjNum(SoMR_Location * location)
    # noinspection PyPep8Naming
    int32_t SoMR_Location_GetEventNum(SoMR_Location* location)
    # noinspection PyPep8Naming
    int32_t SoMR_Location_GetEventIndex(SoMR_Location* location)
    # noinspection PyPep8Naming
    uint8_t SoMR_Location_GetLocationId(SoMR_Location* location)
    # noinspection PyPep8Naming
    void SoMR_Location_Unref(SoMR_Location* location)
    # noinspection PyPep8Naming
    SoMR_StrList* SoMR_Location_GetRequirements(SoMR_Location* location)

    # noinspection PyPep8Naming
    void SoMR_OWSettings_SetStr(SoMR_OWSettings* settings, char16_t* key, char16_t* value)
    # noinspection PyPep8Naming
    char16_t* SoMR_OWSettings_Dump(SoMR_OWSettings* settings)
    # noinspection PyPep8Naming
    void SoMR_OWSettings_Unref(SoMR_OWSettings* settings)

    # noinspection PyPep8Naming
    SoMR_ItemList* SoMR_OWGenerator_GetItems(SoMR_OWGenerator* generator)
    # noinspection PyPep8Naming
    SoMR_LocationList* SoMR_OWGenerator_GetLocations(SoMR_OWGenerator* generator)
    # noinspection PyPep8Naming
    void SoMR_OWGenerator_Unref(SoMR_OWGenerator* generator)

    # noinspection PyPep8Naming
    char16_t * SoMR_Context_GetError(SoMR_Context* context)
    # noinspection PyPep8Naming
    SoMR_WorkingData* SoMR_Context_GetWorkingData(SoMR_Context* context)
    # noinspection PyPep8Naming
    void SoMR_Context_Unref(SoMR_Context* context)

    # noinspection PyPep8Naming
    char16_t* SoMR_WorkingData_GetStr(SoMR_WorkingData* data, char16_t* key)
    # noinspection PyPep8Naming
    void SoMR_WorkingData_SetStr(SoMR_WorkingData * data, char16_t * key, char16_t * value)
    # noinspection PyPep8Naming
    char16_t* SoMR_WorkingData_Dump(SoMR_WorkingData* data)
    # noinspection PyPep8Naming
    void SoMR_WorkingData_Unref(SoMR_WorkingData* data)

    # noinspection PyPep8Naming
    int32_t SoMR_StrList_Count(SoMR_StrList* lst)
    # noinspection PyPep8Naming
    char16_t* SoMR_StrList_At(SoMR_StrList* lst, int32_t index)
    # noinspection PyPep8Naming
    void SoMR_StrList_Unref(SoMR_StrList* lst)

    # noinspection PyPep8Naming
    void SoMR_Str_Free(char16_t* string)


# TODO: move into enum?
WORKING_DATA_KEY_BOY_CLASS = "boyClass"
WORKING_DATA_KEY_GIRL_CLASS = "girlClass"
WORKING_DATA_KEY_SPRITE_CLASS = "spriteClass"
WORKING_DATA_KEY_BOY_EXISTS = "boyExists"  # exists + !in_logic = start_with
WORKING_DATA_KEY_GIRL_EXISTS = "girlExists"
WORKING_DATA_KEY_SPRITE_EXISTS = "spriteExists"
WORKING_DATA_KEY_BOY_IN_LOGIC = "findBoy"
WORKING_DATA_KEY_GIRL_IN_LOGIC = "findGirl"
WORKING_DATA_KEY_SPRITE_IN_LOGIC = "findSprite"
WORKING_DATA_KEY_BOY_START_WEAPON_INDEX = "boyStartWeapon"
WORKING_DATA_KEY_GIRL_START_WEAPON_INDEX = "girlStartWeapon"
WORKING_DATA_KEY_SPRITE_START_WEAPON_INDEX = "spriteStartWeapon"
# possible class values: OGboy, OGgirl, OGsprite, random, randomunique
OW_SETTINGS_KEY_BOY_CLASS = "opBoyRole"
OW_SETTINGS_KEY_GIRL_CLASS = "opGirlRole"
OW_SETTINGS_KEY_SPRITE_CLASS = "opSpriteRole"


cdef size_t ucs2_len(char16_t* data):
    cdef size_t i = 0
    while data[i] != 0:
        i += 1
    return i


cdef str ucs2_to_str(char16_t* data):
    return (<char *> data)[:ucs2_len(data) * 2].decode("UTF-16")


# noinspection PyUnresolvedReferences
cdef bytes str_to_ucs2(str data):
    # FIXME: there has to be a better way to do this
    cdef bytes encoded
    encoded = data.encode("UTF-16")
    if encoded[:2] == b"\xff\xfe" or encoded[:2] == b"\xfe\xff":
        return encoded[2:] + b'\0'  # strip BOM
    return encoded + b'\0'


@cython.auto_pickle(False)
cdef class Item:
    cdef SoMR_Item* _handle;

    @staticmethod
    cdef Item from_handle(SoMR_Item* handle):
        self = Item()
        self._handle = handle
        return self

    def __del__(self) -> None:
        SoMR_Item_Unref(self._handle)

    @property
    def name(self) -> str:
        name_ucs2 = SoMR_Item_GetName(self._handle)
        try:
            # noinspection PyTypeChecker
            return ucs2_to_str(name_ucs2)
        finally:
            SoMR_Str_Free(name_ucs2)

    @property
    def type(self) -> str:
        type_ucs2 = SoMR_Item_GetType(self._handle)
        try:
            # noinspection PyTypeChecker
            return ucs2_to_str(type_ucs2)
        finally:
            SoMR_Str_Free(type_ucs2)

    @property
    def event_flag(self) -> int:
        return SoMR_Item_GetEventFlag(self._handle)

    @property
    def id(self) -> int:
        return SoMR_Item_GetItemId(self._handle)


@cython.auto_pickle(False)
cdef class Location:
    cdef SoMR_Location* _handle;

    @staticmethod
    cdef Location from_handle(SoMR_Location* handle):
        self = Location()
        self._handle = handle
        return self

    def __del__(self) -> None:
        SoMR_Location_Unref(self._handle)

    @property
    def name(self) -> str:
        name_ucs2 = SoMR_Location_GetName(self._handle)
        try:
            # noinspection PyTypeChecker
            return ucs2_to_str(name_ucs2)
        finally:
            SoMR_Str_Free(name_ucs2)

    @property
    def map_num(self) -> int:
        return SoMR_Location_GetMapNum(self._handle)

    @property
    def obj_num(self) -> int:
        return SoMR_Location_GetObjNum(self._handle)

    @property
    def event_num(self) -> int:
        return SoMR_Location_GetEventNum(self._handle)

    @property
    def event_index(self) -> int:
        return SoMR_Location_GetEventIndex(self._handle)

    @property
    def id(self) -> int:
        return SoMR_Location_GetLocationId(self._handle)

    @property
    def requirements(self) -> StrList:
        # noinspection PyTypeChecker
        return StrList.from_handle(SoMR_Location_GetRequirements(self._handle))


@cython.auto_pickle(False)
cdef class ItemList:
    cdef SoMR_ItemList* _handle;

    @staticmethod
    cdef ItemList from_handle(SoMR_ItemList* handle):
        self = ItemList()
        self._handle = handle
        return self

    def __del__(self) -> None:
        SoMR_ItemList_Unref(self._handle)

    def __len__(self) -> int:
        return SoMR_ItemList_Count(self._handle)

    def __iter__(self) -> t.Iterator[Item]:
        for i in range(0, len(self)):
            yield Item.from_handle(SoMR_ItemList_At(self._handle, i))  # noqa


@cython.auto_pickle(False)
cdef class LocationList:
    cdef SoMR_LocationList* _handle;

    @staticmethod
    cdef LocationList from_handle(SoMR_LocationList* handle):
        self = LocationList()
        self._handle = handle
        return self

    def __del__(self) -> None:
        SoMR_LocationList_Unref(self._handle)

    def __len__(self) -> int:
        return SoMR_LocationList_Count(self._handle)

    def __iter__(self) -> t.Iterator[Location]:
        for i in range(0, len(self)):
            yield Location.from_handle(SoMR_LocationList_At(self._handle, i))  # noqa


@cython.auto_pickle(False)
cdef class StrList:
    cdef SoMR_StrList* _handle;

    @staticmethod
    cdef StrList from_handle(SoMR_StrList* handle):
        self = StrList()
        self._handle = handle
        return self

    def __del__(self) -> None:
        SoMR_StrList_Unref(self._handle)

    def __len__(self) -> int:
        return SoMR_StrList_Count(self._handle)

    def __iter__(self) -> t.Iterator[str]:
        for i in range(0, len(self)):  # TODO: while not NULL instead
            value_ucs2 = SoMR_StrList_At(self._handle, i)
            try:
                # noinspection PyTypeChecker
                yield ucs2_to_str(value_ucs2)
            finally:
                SoMR_Str_Free(value_ucs2)


@cython.auto_pickle(False)
cdef class OWSettings:
    cdef SoMR_OWSettings* _handle;

    @staticmethod
    cdef OWSettings from_handle(SoMR_OWSettings* handle):
        self = OWSettings()
        self._handle = handle
        return self

    def __del__(self) -> None:
        SoMR_OWSettings_Unref(self._handle)

    def __str__(self) -> str:
        s_ucs2 = SoMR_OWSettings_Dump(self._handle)
        try:
            # noinspection PyTypeChecker
            return ucs2_to_str(s_ucs2)
        finally:
            SoMR_Str_Free(s_ucs2)

    cdef SoMR_OWSettings* get_handle(self):
        return self._handle

    def __setitem__(self, key: str, value: str) -> None:
        # noinspection PyTypeChecker
        key_bytes = str_to_ucs2(key)
        cdef unsigned char* key_ptr = key_bytes
        # noinspection PyTypeChecker
        value_bytes = str_to_ucs2(value)
        cdef unsigned char* value_ptr = value_bytes
        SoMR_OWSettings_SetStr(self._handle, <char16_t*>key_ptr, <char16_t*>value_ptr)


@cython.auto_pickle(False)
cdef class OWGenerator:
    cdef SoMR_OWGenerator* _handle;

    @staticmethod
    cdef OWGenerator from_handle(SoMR_OWGenerator* handle):
        self = OWGenerator()
        self._handle = handle
        return self

    def __del__(self) -> None:
        SoMR_OWGenerator_Unref(self._handle)

    cdef SoMR_OWGenerator* get_handle(self):
        return self._handle

    def get_items(self) -> ItemList:
        # noinspection PyTypeChecker
        return ItemList.from_handle(SoMR_OWGenerator_GetItems(self._handle))

    def get_locations(self) -> LocationList:
        # noinspection PyTypeChecker
        return LocationList.from_handle(SoMR_OWGenerator_GetLocations(self._handle))


@cython.auto_pickle(False)
cdef class Context:
    cdef SoMR_Context* _handle
    _working_data: WorkingData | None

    @staticmethod
    cdef Context from_handle(SoMR_Context* handle):
        self = Context()
        self._handle = handle
        return self

    def __init__(self):
        self._working_data = None

    def __del__(self) -> None:
        SoMR_Context_Unref(self._handle)

    cdef SoMR_Context* get_handle(self):
        return self._handle

    @property
    def working_data(self) -> WorkingData:
        if self._working_data is None:
            # noinspection PyTypeChecker
            self._working_data = WorkingData.from_handle(SoMR_Context_GetWorkingData(self._handle))
        return self._working_data

    @property
    def error(self) -> str | None:
        msg_ucs2 = SoMR_Context_GetError(self._handle)
        if not msg_ucs2:
            return None
        try:
            # noinspection PyTypeChecker
            return ucs2_to_str(msg_ucs2)
        finally:
            SoMR_Str_Free(msg_ucs2)


@cython.auto_pickle(False)
cdef class WorkingData:
    cdef SoMR_WorkingData* _handle;

    @staticmethod
    cdef WorkingData from_handle(SoMR_WorkingData* handle):
        self = WorkingData()
        self._handle = handle
        return self

    def __del__(self) -> None:
        SoMR_WorkingData_Unref(self._handle)

    def __str__(self) -> str:
        s_ucs2 = SoMR_WorkingData_Dump(self._handle)
        try:
            # noinspection PyTypeChecker
            return ucs2_to_str(s_ucs2)
        finally:
            SoMR_Str_Free(s_ucs2)

    def __getitem__(self, item: str) -> str:
        # TODO: make keys opaque and cache in .net land?
        # noinspection PyTypeChecker
        key_bytes = str_to_ucs2(item)
        cdef unsigned char* key_ptr = key_bytes;
        val_ucs2 = SoMR_WorkingData_GetStr(self._handle, <char16_t*>key_ptr)
        try:
            # noinspection PyTypeChecker
            return ucs2_to_str(val_ucs2)
        finally:
            SoMR_Str_Free(val_ucs2)

    def __setitem__(self, key: str, value: str) -> None:
        # noinspection PyTypeChecker
        key_bytes = str_to_ucs2(key)
        cdef unsigned char* key_ptr = key_bytes
        # noinspection PyTypeChecker
        value_bytes = str_to_ucs2(value)
        cdef unsigned char* value_ptr = value_bytes
        SoMR_WorkingData_SetStr(self._handle, <char16_t*>key_ptr, <char16_t*>value_ptr)


    def get_bool(self, item: str) -> bool:
        s = self[item]
        if s == "yes":
            return True
        if s == "no":
            return False
        raise TypeError(f"{item} is {s}, which is not a boolean")

    def get_int(self, item: str) -> int:
        return int(self[item])


@cython.auto_pickle(False)
cdef class OW:
    _settings: OWSettings
    _generator: OWGenerator
    _context: Context | None
    _seed: str

    @staticmethod
    def get_all_items() -> ItemList:
        # noinspection PyTypeChecker
        return ItemList.from_handle(SoMR_OW_GetAllItems())

    @staticmethod
    def get_all_locations() -> LocationList:
        # noinspection PyTypeChecker
        return LocationList.from_handle(SoMR_OW_GetAllLocations())

    @staticmethod
    cdef OWSettings _new_settings():
        # noinspection PyTypeChecker
        return OWSettings.from_handle(SoMR_OW_NewSettings())

    @staticmethod
    cdef OWGenerator _new_generator():
        # noinspection PyTypeChecker
        return OWGenerator.from_handle(SoMR_OW_NewGenerator())

    def __init__(self, src: str | pathlib.Path, seed: str, settings: dict[str, str]) -> None:
        # noinspection PyTypeChecker
        self._settings = OW._new_settings()
        for key, value in settings.items():
            self._settings[key] = value
        # noinspection PyTypeChecker
        self._generator = OW._new_generator()
        self._context = None
        self._seed = seed
        self._init(str(src))

    cdef void _init(self, src: str):
        # noinspection PyTypeChecker
        src_bytes = str_to_ucs2(src)
        cdef unsigned char* src_ptr = src_bytes
        # noinspection PyTypeChecker
        seed_bytes = str_to_ucs2(self._seed)
        cdef unsigned char* seed_ptr = seed_bytes
        handle = SoMR_OW_Init(
            <char16_t*>src_ptr,
            <char16_t*>seed_ptr,
            self._generator.get_handle(),
            self._settings.get_handle(),
        )
        # noinspection PyTypeChecker
        self._context = Context.from_handle(handle)
        error = self._context.error
        if error:
            raise Exception(error)

    def run(self, dst: str | pathlib.Path) -> None:
        # noinspection PyTypeChecker
        dst_bytes = str_to_ucs2(str(dst))
        cdef unsigned char* dst_ptr = dst_bytes
        # noinspection PyTypeChecker
        seed_bytes = str_to_ucs2(self.seed)
        cdef unsigned char* seed_ptr = seed_bytes
        SoMR_OW_Run(
            <char16_t*>dst_ptr,
            <char16_t*>seed_ptr,
            self._generator.get_handle(),
            self._settings.get_handle(),
            self._context.get_handle(),
        )
        error = self._context.error
        if error:
            raise Exception(error)

    @property
    def seed(self) -> str:
        return self._seed

    @property
    def generator(self) -> OWGenerator:
        return self._generator

    @property
    def settings(self) -> OWSettings:
        return self._settings

    @property
    def context(self) -> Context | None:
        return self._context
