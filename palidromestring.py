def say_hello():
    print('Hello, World')

for i in range(5):
    say_hello()


# 
# Your previous Plain Text content is preserved below:
# 
# Welcome to your interviewing.io interview.
# 
# Once you and your partner have joined, a voice call will start automatically.
# 
# Use the language dropdown near the top right to select the language you would like to use.
# 
# You can run code by hitting the 'Run' button near the top left.
# 
# Enjoy your interview!

# Given a string which we can delete at most k, return whether you can make a palindrome
def find_pali(string,rev_string,index_1,index_2):
    dp=[[0]*(index_1+1) for _ in range(index_2+1)]
    for i in range(index_1+1):
        for j in range(index_2+1):
            if i==0:
                dp[i][j]=j
            elif j==0:
                dp[i][j]=i
        
            if string[i-1]==rev_string[j-1]:
                dp[i][j]=dp[i-1][j-1]
            else:
                
                dp[i][j]=1 + min(dp[i-1][j],dp[i][j-1])
    return dp[index_1][index_2]

def palidrome(string, k):
    string_back=string[::-1]
    string_len=len(string)
    
    answer=find_pali(string,string_back,string_len,string_len)
    return(answer,k,k>=answer)
        
print(palidrome("ROTSGTAASOR",3))
        
def k_palindrome_3(s: str, k: int):
    def longest_palindromic_subsequence(s: str) -> int:
        if len(s) < 2:
            return len(s)

        return (2 + longest_palindromic_subsequence(s[1:-1])
                if s[0] == s[-1] else
                max(longest_palindromic_subsequence(s[1:]), longest_palindromic_subsequence(s[:-1])))

    def longest_palindromic_subsequence_optimized(s: str) -> int:
        n = len(s)
        prev, curr = [[0] * n for _ in range(2)]

        for i in range(n - 1, -1, -1):
            prev, curr = curr, prev
            curr[i] = 1
            for j in range(i + 1, n):
                curr[j] = 2 + prev[j - 1] if s[i] == s[j] else max(prev[j], curr[j - 1])
        return curr[-1]

    return len(s) - longest_palindromic_subsequence_optimized(s) <= k

def k_palindrome_2(s, k):
    def minimum_deletion_needed_for_palindromic_subsequence(s: str) -> int:
        if len(s) < 2:
            return 0

        return (minimum_deletion_needed_for_palindromic_subsequence(s[1:-1])
                if s[0] == s[-1] else
                1 + min(minimum_deletion_needed_for_palindromic_subsequence(s[1:]),
                        minimum_deletion_needed_for_palindromic_subsequence(s[:-1])))

    def minimum_deletion_needed_for_palindromic_subsequence_optimized(s: str) -> int:
        n = len(s)
        prev, curr = [[0] * n for _ in range(2)]

        for i in range(n - 1, -1, -1):
            curr, prev = prev, curr
            curr[i] = 0
            for j in range(i + 1, n):
                curr[j] = prev[j - 1] if s[i] == s[j] else 1 + min(prev[j], curr[j - 1])

        return curr[-1]

    return minimum_deletion_needed_for_palindromic_subsequence_optimized(s) <= k


def k_palindrome_naive(s: str, k: int) -> bool:
    if len(s) <= 1 or k == 0:
        return s == s[::-1]

    return (k_palindrome_naive(s[1:-1], k)
            if s[0] == s[-1] else
            (k_palindrome_naive(s[1:], k - 1) or k_palindrome_naive(s[:-1], k - 1)))


def k_palindrome_1(s: str, k: int) -> bool:
    def is_pal(s, left, right):
        while left < right:
            if s[left] != s[right]:
                return False
            left, right = left + 1, right - 1
        return True

    def helper(left, right, k):
        if (left, right) in memo:
            return memo[(left, right)]

        if left >= right or k == 0:
            memo[(left, right)] = is_pal(s, left, right)
        else:
            memo[(left, right)] = (helper(left + 1, right - 1, k)
                                   if s[left] == s[right] else
                                   helper(left + 1, right, k - 1) or helper(left, right - 1, k - 1))
        return memo[(left, right)]

    memo = {}
    return helper(0, len(s) - 1, k)

