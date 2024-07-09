template <typename Iterator>
class Paginator {
    public:
        Paginator(Iterator begin, Iterator end, int page_size):
        begin_(begin),
        end_(end),
        page_size_(page_size) 
        {
            pages_ = SetPages(begin, end, page_size);
        }

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

            auto begin() const {
                return pages_.begin();
            }

            auto end() const  {
                return pages_.end();
            }


    private:
        Iterator begin_;
        Iterator end_;
        int page_size_;
        vector<IteratorRange> pages_;

        IteratorRange SetPage(Iterator page_begin, int page_size) {
            return IteratorRange(page_begin, page_size);
        }

        vector<IteratorRange> SetPages(Iterator begin, Iterator end, int page_size) {
            vector<IteratorRange> pages;
            int container_size = distance(begin, end);
            for (int i = 0; i <= container_size; i + page_size) {
                    advance(begin, i);
                    pages.push_back(SetPage(begin, page_size));
            }
            return pages;
        }
};
