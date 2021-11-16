import typing
from typing import (
    Any,
    Callable,
    Final,
    Generic,
    Iterable,
    Literal,
    Optional,
    Protocol,
    Tuple,
    TypeVar,
    Union,
)

class _SupportsRead(Protocol):
    def read(self, size: int = ...) -> str:
        ...

_T = TypeVar('_T')

class _SupportsWrite(Generic[_T]):
    def write(self, s: _T) -> None:
        ...

@typing.final
class Options:
    quotationmark: Final[str] = ...
    tojson: Final[Optional[str]] = ...
    mappingtypes: Final[Tuple[type, ...]] = ...

    def __init__(
        self, *,
        quotationmark: Optional[str] = ...,
        tojson: Optional[str],
        mappingtypes: Optional[Tuple[type, ...]],
    ) -> None:
        ...

    def update(
        self, *,
        quotationmark: Optional[str] = ...,
        tojson: Optional[str],
        mappingtypes: Optional[Tuple[type, ...]],
    ) -> Options:
        ...

def decode(data: str, maxdepth: Optional[int] = ..., some: bool = ...) -> Any:
    ...

def decode_latin1(
    data: bytes, maxdepth: Optional[int] = ..., some: bool = ...,
) -> Any:
    ...

def decode_utf8(
    data: bytes, maxdepth: Optional[int] = ..., some: bool = ...,
) -> Any:
    ...

def decode_buffer(
    data: bytes,
    maxdepth: Optional[int] = ...,
    some: bool = ...,
    wordlength: Optional[int] = ...,
) -> Any:
    ...

def decode_callback(
    cb: Callable[[_T], Union[str, bytes, bytearray, int, None]],
    maxdepth: Optional[int] = ...,
    some: bool = ...,
    args: Optional[Iterable[_T]] = None,
) -> Any:
    ...

def decode_io(
    fp: _SupportsRead, maxdepth: Optional[int] = ..., some: bool = ...,
) -> Any:
    ...

def encode(
    data: Any, *,
    options: Optional[Options] = ...,
    quotationmark: Optional[str] = ...,
    tojson: Optional[str],
    mappingtypes: Optional[Tuple[type, ...]],
) -> str:
    ...

def encode_bytes(
    data: Any, *,
    options: Optional[Options] = ...,
    quotationmark: Optional[str] = ...,
    tojson: Optional[str],
    mappingtypes: Optional[Tuple[type, ...]],
) -> str:
    ...

_CallbackStr = TypeVar('_CallbackStr', bound=Callable[[str], None])

@typing.overload
def encode_callback(
    data: Any, cb: _CallbackStr, supply_bytes: Literal[False] = ..., *,
    options: Optional[Options] = ...,
    quotationmark: Optional[str] = ...,
    tojson: Optional[str],
    mappingtypes: Optional[Tuple[type, ...]],
) -> _CallbackStr:
    ...

_CallbackBytes = TypeVar('_CallbackBytes', bound=Callable[[bytes], None])

@typing.overload
def encode_callback(
    data: Any, cb: _CallbackBytes, supply_bytes: Literal[True], *,
    options: Optional[Options] = ...,
    quotationmark: Optional[str] = ...,
    tojson: Optional[str],
    mappingtypes: Optional[Tuple[type, ...]],
) -> _CallbackBytes:
    ...

_SupportsWriteBytes = TypeVar('_SupportsWriteBytes', bound=_SupportsWrite[bytes])

@typing.overload
def encode_io(
    data: Any, fp: _SupportsWriteBytes, supply_bytes: Literal[True] = ..., *,
    options: Optional[Options] = ...,
    quotationmark: Optional[str] = ...,
    tojson: Optional[str],
    mappingtypes: Optional[Tuple[type, ...]],
) -> _SupportsWriteBytes:
    ...

_SupportsWriteStr = TypeVar('_SupportsWriteStr', bound=_SupportsWrite[str])

@typing.overload
def encode_io(
    data: Any, fp: _SupportsWriteStr, supply_bytes: Literal[False], *,
    options: Optional[Options] = ...,
    quotationmark: Optional[str] = ...,
    tojson: Optional[str],
    mappingtypes: Optional[Tuple[type, ...]],
) -> _SupportsWriteStr:
    ...

def encode_noop(
    data: Any, *,
    options: Optional[Options] = ...,
    quotationmark: Optional[str] = ...,
    tojson: Optional[str],
    mappingtypes: Optional[Tuple[type, ...]],
) -> bool:
    ...

def loads(s: str, *, encoding: str = ...) -> Any:
    ...

def load(fp: _SupportsRead) -> Any:
    ...

def dumps(obj: Any) -> str:
    ...

def dump(obj: Any, fp: _SupportsWrite[str]) -> None:
    ...

class Json5Exception(Exception):
    def __init__(self, message: Optional[str] = ..., *args: Any) -> None:
        ...

    @property
    def message(self) -> Optional[str]:
        ...

class Json5EncoderException(Json5Exception):
    ...

class Json5UnstringifiableType(Json5EncoderException):
    def __init__(
        self, message: Optional[str] = ..., unstringifiable: Any = ...,
    ) -> None:
        ...

    @property
    def unstringifiable(self) -> Any:
        ...

class Json5DecoderException(Json5Exception):
    def __init__(
        self, message: Optional[str] = ..., result: Any = ..., *args: Any,
    ) -> None:
        ...

@typing.final
class Json5NestingTooDeep(Json5DecoderException):
    ...

@typing.final
class Json5EOF(Json5DecoderException):
    ...

@typing.final
class Json5IllegalCharacter(Json5DecoderException):
    def __init__(
        self,
        message: Optional[str] = ...,
        result: Any = ...,
        character: Optional[str] = ...,
        *args: Any,
    ) -> None:
        ...

    @property
    def character(self) -> Optional[str]:
        ...

@typing.final
class Json5ExtraData(Json5DecoderException):
    def __init__(
        self,
        message: Optional[str] = ...,
        result: Any = ...,
        character: Optional[str] = ...,
        *args: Any,
    ) -> None:
        ...

    @property
    def character(self) -> Optional[str]:
        ...

@typing.final
class Json5IllegalType(Json5DecoderException):
    def __init__(
        self,
        message: Optional[str] = ...,
        result: Any = ...,
        value: Optional[str] = ...,
        *args: Any,
    ) -> None:
        ...

    @property
    def value(self) -> Optional[str]:
        ...
