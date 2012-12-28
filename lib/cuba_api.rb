# -*- Coding: utf-8 -*-
require "cuba"

require 'cuba_api/write_aspect'
require 'cuba_api/serializer'
require 'cuba_api/current_user'
require 'cuba_api/guard'
require 'cuba_api/accept_content'
require 'cuba_api/config'

class CubaAPI < Cuba

  plugin CubaApi::Config
  plugin CubaApi::WriteAspect
  plugin CubaApi::Serializer
  plugin CubaApi::AcceptContent
  plugin CubaApi::CurrentUser
  plugin CubaApi::Guard

end
