// See http://unriskinsight.blogspot.com/2014/06/fast-functional-goats-lions-and-wolves.html
// Sascha Kratky (kratky@unrisk.com), uni software plus GmbH & MathConsult GmbH
//
// compilation requires a C++11 compliant compiler.
//
// compile with Clang 3.4:
// clang++ -O3 -std=c++11 -stdlib=libc++ magic_forest.cpp -o magic_forest
//
// to compile with GCC 4.9:
// g++ -O3 -std=c++11 magic_forest.cpp -o magic_forest
//
// compile with Visual Studio 2013:
// "C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\vcvarsall.bat"
// cl /EHsc /O2 magic_forest.cpp
//
// run:
// magic_forest 117 155 106

#include <algorithm>
#include <array>
#include <cstdlib>
#include <functional>
#include <iostream>
#include <iterator>
#include <numeric>
#include <sstream>
#include <utility>
#include <vector>

namespace {

    typedef std::array<int,3> forest_t;

    bool forest_stable(const forest_t& forest) {
        return std::count(std::begin(forest), std::end(forest), 0) >= 2;
    }

    bool forest_invalid(const forest_t& forest) {
        return std::any_of(std::begin(forest), std::end(forest),
            std::bind(std::less<int>(), std::placeholders::_1, 0));
    }

    std::vector<forest_t> meal(const std::vector<forest_t>& forests) {
        static const std::array<forest_t,3> possible_meals = {{
            forest_t{{-1,-1,+1}},
            forest_t{{-1,+1,-1}},
            forest_t{{+1,-1,-1}}
        }};
        // apply possible meals to all forests
        std::vector<forest_t> next_forests;
        next_forests.reserve(forests.size() * possible_meals.size());
        for (auto meal: possible_meals) {
            forest_t next_forest;
            std::transform(std::begin(forests), std::end(forests),
                std::back_inserter(next_forests),
                [&](const forest_t& forest) {
                    std::transform(std::begin(forest), std::end(forest),
                        std::begin(meal), std::begin(next_forest), std::plus<int>());
                    return next_forest;
                });
        }
        // filter valid forests
        auto valid_end = std::remove_if(std::begin(next_forests), std::end(next_forests),
            forest_invalid);
        // delete duplicates
        std::stable_sort(std::begin(next_forests), valid_end);
        next_forests.erase(
            std::unique(std::begin(next_forests), valid_end), std::end(next_forests));
        return next_forests;
    }

    bool devouring_possible(const std::vector<forest_t>& forests) {
        return !forests.empty() && std::none_of(std::begin(forests),
            std::end(forests), forest_stable);
    }

    std::vector<forest_t> stable_forests(const std::vector<forest_t>& forests) {
        std::vector<forest_t> stable_forests;
        std::copy_if(std::begin(forests), std::end(forests),
            std::back_inserter(stable_forests), forest_stable);
        return stable_forests;
    }

    std::vector<forest_t> find_stable_forests(const forest_t& forest) {
        std::vector<forest_t> forests = { forest };
        while (devouring_possible(forests)) {
            forests = meal(forests);
        }
        return stable_forests(forests);
    }

}

int main(int argc, char* argv[])
{
    if (argc != 4) {
        std::cerr << "USAGE: " << argv[0] << " <goats> <wolves> <lions>" << std::endl;
        std::exit(EXIT_FAILURE);
    }
    try {
        forest_t initial_forest = {{ std::stoi(argv[1]), std::stoi(argv[2]), std::stoi(argv[3]) }};
        std::vector<forest_t> stable_forests = find_stable_forests(initial_forest);
        if (stable_forests.empty()) {
            std::cout << "no stable forests found." << std::endl;
        }
        else {
            for (auto forest: stable_forests) {
                std::ostringstream oss;
                std::copy(std::begin(forest), std::prev(std::end(forest), 1),
                    std::ostream_iterator<int>(oss, ", "));
                oss << forest.back();
                std::cout << oss.str() << std::endl;
            }
        }
    }
    catch (const std::exception& err) {
        std::cerr << "ERROR: " << err.what() << std::endl;
        std::exit(EXIT_FAILURE);
    }
}
