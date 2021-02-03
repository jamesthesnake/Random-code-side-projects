#include <iostream>
#include <iterator>
#include <vector>
#include <array>
#include <algorithm>    // std::max

struct pair {
  
    int b,e;
    
};

// links:
// https://en.cppreference.com/w/cpp/container/vector/insert
// https://en.cppreference.com/w/cpp/algorithm/sort
// https://en.cppreference.com/w/cpp/algorithm/max

/*
stdin:

b
|
1 3
2 5
6 10
9 11
12 15
15 17
     |
     e
*/

bool compare(pair a, pair b)
{
   return a.b<b.b;
}

std::vector<pair> merge(std::vector<pair> vect_list){
    //sort
    std::sort(vect_list.begin(),vect_list.end(),compare);
    int index=0;
    for(int j=1; j<vect_list.size();j++){
        
        if(vect_list[index].e>=vect_list[j].b){
            
            if(vect_list[index].e>=vect_list[j].b){
            vect_list[index].b=std::min(vect_list[index].b,vect_list[j].b);
            vect_list[index].e=std::max(vect_list[index].e,vect_list[j].e);
            }
        }
        else {
            index++;
            vect_list[index]=vect_list[j];
        }
    }
    // https://en.cppreference.com/w/cpp/container/vector/resize
        vect_list.resize(index+1);
        return vect_list;
        
        
    }

int main() {
    auto b = std::istream_iterator<int>(std::cin);
    auto e = std::istream_iterator<int>();
    /* produce your representation of the sequence based on [b, e) */
    std::vector<pair> interval;

    while(b!=e){
        pair p;
        p.b = *b++;
        p.e = *b++;
        interval.push_back(p);
    }

    interval=merge(interval);
    /* invoke your routine for merging the interval sequence */
    
    //auto o = std::ostream_iterator</* your interval type */>(std::cout);
    for (auto p : interval) {
        std::cout << p.b << ' ' << p.e << '\n';
    }
    /* output your representation of the merged sequence to o */

    return 0;
}
