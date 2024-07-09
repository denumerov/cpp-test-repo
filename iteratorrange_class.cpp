class IteratorRange {
        public:
        
            IteratorRange(Iterator range_begin, int range_size):
                begin_(range_begin),
                size_(range_size) {
                    end_ = begin();
                    advance(end_, size()-1);
                }

            Iterator begin() const {
                return begin_;
            }

            Iterator end() const {
                return end_;
            }

            int size() {
                return size_;
            }

        private:
            Iterator begin_;
            Iterator end_;
            int size_;
        };
