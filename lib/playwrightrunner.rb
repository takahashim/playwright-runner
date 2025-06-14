# Playwright Runner
# Copyright 2023 Kenshi Muto
# frozen_string_literal: true

require_relative 'playwrightrunner/version'

require 'playwright'
require 'open3'
require 'fileutils'

module PlaywrightRunner
  def default_config(config)
    config[:playwright_path] ||= './node_modules/.bin/playwright'

    # for Mermaid
    config[:selfcrop] = true if config[:selfcrop].nil?
    config[:pdfcrop_path] ||= 'pdfcrop'
    config[:pdftocairo_path] ||= 'pdftocairo'

    config
  end

  def mermaids_to_images(passed_config, src: '.', dest: '.', type: 'pdf', timeout: 10_000)
    config = default_config(passed_config)
    Playwright.create(playwright_cli_executable_path: config[:playwright_path]) do |playwright|
      playwright.chromium.launch(headless: true, timeout: timeout) do |browser|
        page = browser.new_page
        Dir.glob(File.join(src, '*.html')).each do |entry|
          id = File.basename(entry).sub('.html', '')
          page.goto("file:///#{File.absolute_path(entry)}", timeout: timeout)
          page.locator('svg').wait_for(state: 'visible', timeout: timeout)
          sleep(1)
          1.upto(4) do
            bounds = page.locator('svg').bounding_box

            unless bounds
              sleep(1)
              next
            end

            if config[:selfcrop]
              x = bounds['x'].floor
              y = bounds['y'].floor
              width = bounds['width'].ceil
              height = bounds['height'].ceil
              page.set_viewport_size({ width: x + width, height: y + height })

              if type == 'png'
                page.screenshot(path: File.join(dest, "#{id}.png"), clip: { x: x, y: y, width: width, height: height },
                                timeout: timeout)
                break
              end

              page.pdf(path: File.join(dest, "#{id}.pdf"),
                       width: "#{width + (x * 2)}px",
                       height: "#{height + (y * 2)}px")
            else
              page.pdf(path: File.join(dest, '__PLAYWRIGHT_TMP__.pdf'))
              Open3.capture2e(config[:pdfcrop_path],
                              File.join(dest, '__PLAYWRIGHT_TMP__.pdf'),
                              File.join(dest, "#{id}.pdf"))
            end

            break
          end

          next unless type == 'svg'

          Open3.capture2e(config[:pdftocairo_path],
                          '-svg',
                          '-f',
                          '1',
                          '-l',
                          '1',
                          File.join(dest, "#{id}.pdf"),
                          File.join(dest, "#{id}.svg"))
          FileUtils.rm_f(File.join(dest, "#{id}.pdf"))
        end

        FileUtils.rm_f(File.join(dest, '__PLAYWRIGHT_TMP__.pdf'))
      end
    end
  end

  module_function :mermaids_to_images, :default_config
end
