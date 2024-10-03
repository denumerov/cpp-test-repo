#pragma once
#include "common.h"

class Texture {
public:
    explicit Texture(Image image)
        : image_(std::move(image)) {
    }

    Size GetSize() const {
        // Заглушка. Реализуйте метод самостоятельно
        if(image_.empty() || image_.at(0).empty()) {
            return {0, 0};
        }
        Size result{static_cast<int>(image_.at(0).size()), static_cast<int>(image_.size())};
        return result;
    }

    char GetPixelColor(Point p) const {
        return image_[p.x][p.y];
    }

private:
    Image image_;
};