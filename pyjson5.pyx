# distutils: language = c++
# cython: embedsignature = True, language_level = 3, warn.undeclared = True, warn.unreachable = True, warn.maybe_uninitialized = True

# Copyright 2018-2023 René Kijewski <pypi.org@k6i.de>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

include 'src/_imports.pyx'
include 'src/_constants.pyx'

include 'src/_exceptions.pyx'
include 'src/_exceptions_decoder.pyx'
include 'src/_exceptions_encoder.pyx'
include 'src/_raise_decoder.pyx'
include 'src/_raise_encoder.pyx'

include 'src/_unicode.pyx'

include 'src/_reader_ucs.pyx'
include 'src/_reader_callback.pyx'
include 'src/_readers.pyx'
include 'src/_decoder.pyx'

include 'src/_writers.pyx'
include 'src/_writer_reallocatable.pyx'
include 'src/_writer_callback.pyx'
include 'src/_writer_noop.pyx'
include 'src/_encoder_options.pyx'
include 'src/_encoder.pyx'

include 'src/_exports.pyx'
include 'src/_legacy.pyx'
