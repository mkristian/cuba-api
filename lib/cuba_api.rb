#
# Copyright (C) 2012 Christian Meier
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
# -*- Coding: utf-8 -*-
require "cuba"

require 'cuba_api/write_aspect'
require 'cuba_api/serializer'
require 'cuba_api/current_user'
require 'cuba_api/guard'
require 'cuba_api/accept_content'
require 'cuba_api/config'
require 'cuba_api/input_filter'
require 'cuba_api/response_status'

class CubaAPI < Cuba

  plugin CubaApi::Config
  plugin CubaApi::WriteAspect
  plugin CubaApi::Serializer
  plugin CubaApi::AcceptContent
  plugin CubaApi::CurrentUser
  plugin CubaApi::Guard
  plugin CubaApi::InputFilter
  plugin CubaApi::ResponseStatus

end
