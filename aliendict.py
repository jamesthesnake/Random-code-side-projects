import copy
class Solution:
    
    def visit(self,word_dict,letter,visited,output):
        visited.extend(letter)
        print(letter,visited,output)
        if letter:

                visited,ouput=self.visit(word_dict,word_dict[letter[0]],visited,output)
        else:
            
                return visited,output
        output.extend(letter)
        return visited,output
    def top_sort(self,word_dict,word_dict_childern):
        seen=[]
        output=[]
        
        for letter,parents in word_dict.items():
            if letter not in seen:
                       seen,output=self.visit(word_dict,letter,seen,output)
        print(seen,output)
        return seen


    def alienOrder(self, word_list: List[str]) -> str:
        word_dict={letter:[] for words in word_list for letter in words}
        word_dict_childern={letter:[] for words in word_list for letter in words}
        for word_index in range(len(word_list)-1):
            first_word=word_list[word_index]
            second_word=word_list[word_index+1]
            for letter in range(min(len(first_word),len(second_word))):
                print(word_dict,first_word[letter])
                if first_word[letter]!=second_word[letter]:
                    word_dict[first_word[letter]].extend(second_word[letter][0])
                    word_dict_childern[second_word[letter]].extend(first_word[letter][0])
                    break
            for word,value in word_dict.items():
                for other,val in word_dict_childern.items():
                    if other and word and val and value:
                        if other==word and val==value:
                            return ""
        print(word_dict,word_dict_childern)
        join= self.top_sort(word_dict,word_dict_childern)
        return_string=""
        for j in join:
            return_string+=j
        return return_string


