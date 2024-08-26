#pragma once

#include "array_ptr.h"

#include <algorithm>
#include <cassert>
#include <initializer_list>
#include <iterator>
#include <stdexcept>
#include <string>
#include <utility>

struct Capacity {
    
    Capacity() = default;

    Capacity(size_t capacity_value){
        capacity = capacity_value;
    }

    size_t capacity = 0;
};

Capacity Reserve(size_t capacity_to_reserve) {
    return Capacity(capacity_to_reserve);
}

template <typename Type>
class SimpleVector {
public:
    using Iterator = Type*;
    using ConstIterator = const Type*;

    SimpleVector() noexcept = default;
    
    SimpleVector(size_t size, const Type& value):
        size_(size),
        capacity_(size),
        items_(size) {
            std::fill(items_.Get(), items_.Get() + size, value);
    }

    SimpleVector(size_t size) : SimpleVector(size, Type{}) {}

    SimpleVector(std::initializer_list<Type> init):
        size_(init.size()),
        capacity_(init.size()),
        items_(init.size()) {
        ArrayPtr<Type> tmp(init.size());
        std::copy(init.begin(), init.end(), tmp.Get());
        tmp.swap(items_);
    }

    SimpleVector(const SimpleVector& other):
        size_(other.size_),
        capacity_(other.capacity_) {
        ArrayPtr<Type> tmp(other.GetSize());
        std::copy(other.begin(), other.end(), tmp.Get());
        tmp.swap(items_);
    }

    SimpleVector(SimpleVector&& other) noexcept {
        ArrayPtr<Type> tmp(std::move(other.items_));
        tmp.swap(items_);
        size_ = std::exchange(other.size_, 0);
        capacity_ = std::exchange(other.capacity_, 0);
    }

    SimpleVector(const Capacity& new_capacity) {
        ArrayPtr<Type> tmp(new_capacity.capacity);
        tmp.swap(items_);
        size_ = 0;
        capacity_ = new_capacity.capacity;
    }

    SimpleVector& operator=(const SimpleVector& rhs) {
        if (*this != rhs) {
            SimpleVector<Type> tmp(rhs);
            tmp.swap(*this);
        }
        if (rhs.IsEmpty()){
            this->Clear();
        }
        return *this;
    }

    SimpleVector& operator=(SimpleVector&& rhs) {
        if (*this != rhs) {
            if (rhs.IsEmpty()){
                this->Clear();
                return *this;
            }
            ArrayPtr<Type> tmp(std::move(rhs.items_)); 
            tmp.swap(rhs.items_); 
            size_ = rhs.size_; 
            capacity_ = rhs.capacity_;
        }
        return *this;
    }

    void Reserve(size_t new_capacity) {
        if (new_capacity <= capacity_) {
            return;
        }
        ArrayPtr<Type> tmp(new_capacity);
        std::copy(items_.Get(), items_.Get() + size_, tmp.Get());
        tmp.swap(items_);
        capacity_ = new_capacity;
    }

    void PushBack(const Type& item) {
        if (size_ == capacity_){
            size_t new_size;
            if (capacity_ == 0){
                new_size = 1;
            } else {
                new_size = size_ * 2;
            }
            this->Reserve(new_size);
            this->operator[size_] = item;
            ++size_;
        } else {
            items_[size_] = item;
            ++size_;
        }
    }

    void PushBack(Type&& item) {
        if (size_ == capacity_){
            size_t new_size;
            if (capacity_ == 0){
                new_size = 1;
            } else {
                new_size = size_ * 2;
            }
            ArrayPtr<Type> tmp(new_size);
            std::move(items_.Get(), items_.Get() + size_, tmp.Get());
            tmp[size_] = std::move(item);
            tmp.swap(items_);
            ++size_;
            capacity_ = new_size;
        } else {
            items_[size_] = std::move(item);
            ++size_;
        }
    }

    Iterator Insert(ConstIterator pos, const Type& value) { 
        if(size_ == capacity_) {
            size_t new_size;
            if (capacity_ == 0){
                new_size = 1;
            } else {
                new_size = size_ * 2;
            }
            ArrayPtr<Type> tmp(new_size);
            size_t offset = pos - begin();
            std::copy(items_.Get(), items_.Get() + offset, tmp.Get());
            tmp[offset] = value;
            std::copy_backward(items_.Get() + offset, items_.Get() + size_, tmp.Get() + size_ + 1);
            tmp.swap(items_);
            ++size_;
            capacity_ = new_size;
            return &items_[offset];
        } else {
            size_t offset = pos - begin();;
            std::copy_backward(items_.Get() + offset, items_.Get() + size_, items_.Get() + size_ + 1);
            items_[offset] = value;
            ++size_;
            return &items_[offset];
        }
    }

    Iterator Insert(ConstIterator pos, Type&& value) {
        if(size_ == capacity_){
            size_t new_size;
            if (capacity_ == 0){
                new_size = 1;
            } else {
                new_size = size_ * 2;
            }
            ArrayPtr<Type> tmp(new_size);
            size_t offset = pos - begin();
            std::move(items_.Get(), items_.Get() + offset, tmp.Get());
            tmp[offset] = std::move(value);
            std::move_backward(items_.Get() + offset, items_.Get() + size_, tmp.Get() + size_ + 1);
            tmp.swap(items_);
            ++size_;
            capacity_ = new_size;
            return &items_[offset];
        } else {
            size_t offset = pos - begin();;
            std::move_backward(items_.Get() + offset, items_.Get() + size_, items_.Get() + size_ + 1);
            items_[offset] = std::move(value);
            ++size_;
            return &items_[offset];
        }
    }
    
    void PopBack() noexcept {
        assert(size_ != 0);
        --size_;
    }

    Iterator Erase(ConstIterator pos) {
        assert(GetSize() != 0);
        size_t offset = pos - begin();
        std::move(items_.Get() + offset + 1, items_.Get() + size_, items_.Get() + offset);
        --size_;
        return items_.Get() + offset;
    }

    void swap(SimpleVector& other) noexcept {
        
        items_.swap(other.items_);
        std::swap(other.size_, size_);
        std::swap(other.capacity_, capacity_);
    }

    size_t GetSize() const noexcept {
        return size_;
    }

    size_t GetCapacity() const noexcept {
        
        return capacity_;
    }

    bool IsEmpty() const noexcept {
        return size_ == 0;
    }

    Type& operator[](size_t index) noexcept {
        return items_[index];
    }

    const Type& operator[](size_t index) const noexcept {
        return items_[index];
    }

    Type& At(size_t index) {
        if (index >= size_) {
            throw std::out_of_range("Out of range !");
        }
        return items_[index];
    }

    const Type& At(size_t index) const {
        if (index >= size_) {
            throw std::out_of_range("Out of range !");
        }
        return items_[index];
    }

    void Clear() noexcept {
        size_ = 0;
    }
    
    void Resize(size_t new_size) { 
        if (new_size <= size_) {
            size_ = new_size;
        }
        if(new_size > size_ && new_size <= capacity_){
            
            for (size_t i = size_; i < new_size; ++i){
                items_[i] = std::move(Type{});
            }
            size_ = new_size;
        }
        if(new_size > capacity_){
            ArrayPtr<Type> tmp(new_size);
            std::move(items_.Get(), items_.Get() + size_, tmp.Get());
            for (size_t i = size_; i < new_size; ++i){
                tmp[i] = std::move(Type{});
            }
            tmp.swap(items_);
            size_ = new_size;
            capacity_ = 2 * new_size;
        }
    }
    
    Iterator begin() noexcept {
        return items_.Get();
    }
 
    Iterator end() noexcept {
        return items_.Get() + size_;
    }

    ConstIterator begin() const noexcept {   
        return items_.Get();
    }

    ConstIterator end() const noexcept {   
        return items_.Get() + size_;
    }

    ConstIterator cbegin() const noexcept {   
        return begin();
    }
   
    ConstIterator cend() const noexcept {   
        return end();
    }

private:
    size_t size_ = 0;
    size_t capacity_ = 0;

    ArrayPtr<Type> items_;
};

template <typename Type>
inline bool operator==(const SimpleVector<Type>& lhs, const SimpleVector<Type>& rhs) {
    if(lhs.GetSize() == rhs.GetSize()){
        return std::equal(lhs.begin(), lhs.end(), rhs.begin());
    }
    return false;
}

template <typename Type>
inline bool operator!=(const SimpleVector<Type>& lhs, const SimpleVector<Type>& rhs) {
    return !(lhs == rhs);
}

template <typename Type>
inline bool operator<(const SimpleVector<Type>& lhs, const SimpleVector<Type>& rhs) {
    return std::lexicographical_compare(lhs.begin(), lhs.end(), rhs.begin(), rhs.end());
}

template <typename Type>
inline bool operator<=(const SimpleVector<Type>& lhs, const SimpleVector<Type>& rhs) {
    return !(rhs < lhs);
}

template <typename Type>
inline bool operator>(const SimpleVector<Type>& lhs, const SimpleVector<Type>& rhs) {
    return rhs < lhs;
}

template <typename Type>
inline bool operator>=(const SimpleVector<Type>& lhs, const SimpleVector<Type>& rhs) {
    return !(lhs < rhs);
} 

