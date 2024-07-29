bool Preprocess(ifstream& in_file, ofstream& out_file, const path& file_location, const vector<path>& include_directories) {
    smatch m;
    int string_count = 0;
    bool result = false;

    if (!in_file.is_open()) {
        return result;
    }

    bool is_exist = false;
    
    string code_string;
    while (getline(in_file, code_string)) {
        bool res = false;
        ++string_count;
        if(regex_match(code_string, m, local_lib)){
            path local_file = file_location.parent_path()/string(m[1]);
            is_exist = filesystem::exists(local_file);
            if (is_exist) {
                ifstream local_stream(local_file);
                if (local_stream.is_open()) {
                    if (Preprocess(local_stream, out_file, local_file, include_directories)) {
                        res = true;
                        break;
                    }
                } else {res = false;}
            } else {
                for (const path& incl_elem : include_directories) {
                    local_file = incl_elem/string(m[1]);
                    is_exist = filesystem::exists(local_file);
                    if(is_exist) {
                        ifstream local_stream(local_file);
                        if (local_stream.is_open()){
                            if(Preprocess(local_stream, out_file, local_file, include_directories)) {
                                res = true;
                                break;
                            }
                        }
                    } 
                }
            }
        }

        if(regex_match(code_string, m, global_lib)){
            path z = string(m[1]);
            for (const path& incl_elem : include_directories) {
                path global_file = incl_elem/z;
                is_exist = filesystem::exists(global_file);
                if(is_exist) {
                    ifstream global_stream(global_file);
                    if (global_stream.is_open()){
                        if(Preprocess(global_stream, out_file, global_file, include_directories)) {
                            res = true;
                            break;
                        }
                        break;
                    }
                } 
            }
        }

        if(!(regex_match(code_string, m, local_lib)||regex_match(code_string, m, global_lib))) {
            out_file << code_string << endl;
            if (out_file.good()){
                res = true;
            }
            continue;
        } else {
            if (is_exist) {
                continue;
            } else {
                path err = string(m[1]);
                cout << "unknown include file " << err.string() << " at file " <<
                file_location.string() << " at line " << string_count << endl;
                res = false;
                break;
            }
            
        }

        if (res) {
            result = true;
        } else {
            result = false;
        }
        
    }
    return result;
}    

   
// напишите эту функцию
bool Preprocess(const path& in_file, const path& out_file, const vector<path>& include_directories) {
    
    ifstream input(in_file);
    
    if(!input.is_open()) {
        return false;
    }

    ofstream ready_file(out_file);
    return Preprocess(input, ready_file, in_file, include_directories);
}
