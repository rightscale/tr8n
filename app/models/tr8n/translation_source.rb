#--
# Copyright (c) 2010 Michael Berkovich, Geni Inc
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

class Tr8n::TranslationSource < ActiveRecord::Base
  set_table_name :tr8n_translation_sources
  
  belongs_to  :translation_domain,       :class_name => "Tr8n::TranslationDomain"
  
  has_many    :translation_key_sources,  :class_name => "Tr8n::TranslationKeySource",  :dependent => :destroy
  has_many    :translation_keys,         :class_name => "Tr8n::TranslationKey",        :through => :translation_key_sources
  
  def self.find_or_create(source_url)
    source_name = URI.parse(source_url).path || source_url
    source_name = source_name[1..-1] if source_name.first == "/"
    source = find_by_source(source_name) || create(:source => source_name)
    source.update_attributes(:translation_domain => Tr8n::TranslationDomain.find_or_create(source_url)) unless source.translation_domain
    source
  end

  def after_save
    Tr8n::Cache.delete("translation_source_#{id}")
  end

  def after_destroy
    Tr8n::Cache.delete("translation_source_#{id}")
  end
  
end
