module ImageProcessable
  # エラーの出力を行いたいのでStandardErrorクラスをImageProcessingErrorクラスに継承
  class ImageProcessingError < StandardError; end

  # 画像処理メソッド。image_ioにはparams[:post][:image]の中の一時ファイルを渡す
  # widthには横幅の最大値を渡す
  def process_and_transform_image(image_io, width)
    return unless image_io.present?

    begin
      # 横幅の上限だけを適用し、必要以上のアップスケールを避ける
      processed_image = ImageProcessing::Vips
        .source(image_io.tempfile)
        .resize_to_limit(width, nil)
        .convert("webp")
        .saver(strip: true, quality: 85)
        .call

      # ActionDispatch::Http::UploadedFileを返す
      ActionDispatch::Http::UploadedFile.new(
        tempfile: processed_image,
        filename: "#{File.basename(image_io.original_filename, '.*')}.webp",
        type: "image/webp"
      )
    rescue => e
      Rails.logger.error "Image processing error: #{e.class} - #{e.message}"
      raise ImageProcessingError, "画像の処理に失敗しました。別の画像でお試しください。"
    end
  end
end
