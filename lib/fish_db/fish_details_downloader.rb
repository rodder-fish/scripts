# frozen_string_literal: true

require 'httparty'
require 'nokogiri'

module FishDB
  class FishDetailsDownloader
    TERM_NAME_REGEX = /^([A-Z][a-z]+)\s+([a-z\-]+)(?:\s+\((.+?),*\s*(\d{4})\)|\s+(.+?),*\s+(\d{4}))$/
    SIMPLE_TERM_NAME_REGEX = /^([A-Z][a-z]+)\s+([a-z\-]+).*$/

    def download(fish_base_id)
      download_detail(fish_base_id)
    end

    private

    def download_detail(fish_base_id)
      result = {}

      url = "#{FISHDB_DETAIL_URL}/#{fish_base_id}-fishdb"
      response = HTTParty.get(url)
      doc = Nokogiri::HTML(response.body)

      names_wrapper_tag = doc.at_css('.names-wrapper')

      # 學名
      term_name_tag = names_wrapper_tag.at_css('.term-name')
      return unless term_name_tag

      term_name = term_name_tag.text.strip

      if (match = term_name.match(TERM_NAME_REGEX))
        result[:genus] = match[1]
        result[:species] = match[2]
        result[:author] = match[3] || match[5]
        result[:year] = (match[4] || match[6]).to_i
      elsif (match = term_name.match(SIMPLE_TERM_NAME_REGEX))
        result[:genus] = match[1]
        result[:species] = match[2]
      end

      result[:chinese_name] = extract_meta_attr_texts(doc, '中文名').first
      result[:chinese_alias] = extract_meta_attr_texts(doc, '中國大陸俗名').first
      result[:chinese_synonyms] = extract_meta_attr_texts(doc, '其他俗名').flat_map { |s| s.split(',') }.map(&:strip)
      result[:english_synonyms] = extract_meta_attr_texts(doc, '英文俗名').flat_map { |s| s.split(',') }.map(&:strip)
      result[:attributes] = extract_attrs(names_wrapper_tag, '其他屬性')
      result[:habitats] = extract_attrs(names_wrapper_tag, '棲息環境')
      result[:waters] = extract_attrs(names_wrapper_tag, '棲息水域')
      result[:description] = extract_chapter_text(doc, 'spm-description')
      result[:distribution] = extract_chapter_text(doc, 'spm-distribution')
      result[:size_info] = extract_chapter_text(doc, 'spm-size')
      result[:habitat_detail] = extract_chapter_text(doc, 'spm-habitat')
      result[:depth_info] =
        doc.at_css('#spm-habitat .term-meta-attrs label:contains("棲息深度")')&.parent&.css('span.meta-attr')&.map(&:text)
      result[:usage] = extract_chapter_text(doc, 'spm-use')

      result
    end

    def extract_meta_attr_texts(doc, label_text)
      doc.css('div.term-meta-attrs').select do |div|
        div.at_css('label')&.text&.strip == label_text
      end.flat_map do |div|
        div.css('span.meta-attr').map(&:text).map(&:strip)
      end
    end

    def extract_attrs(doc, label_text)
      doc.css('div.term-meta-attrs.taxon-attrs').find do |div|
        div.at_css('label')&.text == label_text
      end&.css('span.meta-attr')&.map(&:text)&.map(&:strip) || []
    end

    def extract_chapter_text(doc, id)
      doc.at_css("##{id} .chapter-body")&.text&.strip || ''
    end
  end
end
