from nltk import word_tokenize
from nltk.stem.porter import PorterStemmer
from nltk.corpus import wordnet as wn


import csv
import re


spreadsheet_path = '../RawScale_ ParticipantEmotionLevels.csv'


# takes in a freqDist and 
# return res: a list of (word, emotion) tuple 
# word(string): word from interview that are similar to some word the scale csv
# emotion(string): the corresponding word in scale
def getEmotion(freqMap):
	res = []
	for word in freqMap:
		isInScale, emotion = inScale(word)
		if isInScale:
			res.append((word,emotion))
	if not res:
		res.append(("no scalable emotion recognized", None))

	return res

# initialize the emotions from the scale
def readEmotions(path):
	with open(path,'rt', encoding = 'utf-8') as csvfile:
		interviewReader = csv.reader(csvfile)
		for row in interviewReader:
			return row[2:]
	return []


# read the calibration from a participant
def readScale(path, participant_num):
	with open(path,'rt', encoding = 'utf-8') as csvfile:
		interviewReader = csv.reader(csvfile)
		for row in interviewReader:
			if row[1] == str(participant_num):
				return row[2:]
	print('participant', participant_num, ' not found')
	return []


# If check_negation=False, same with nltk word_tokenize
# check negation finds all the "not" and "n't" in the interview
# and log (time_stamp, phrase containing negation) to console
def tokenize(string, check_negation=False, time_stamp=None):
	def find_all(string, target):
		return [m.start() for m in re.finditer(target, string)]

	res = word_tokenize(string)
	if (check_negation and ("n't" in res or "not" in res)):
		assert time_stamp, "To generate a report of negation, please pass in the time stamp."
		for i in find_all(string, "not"):
			print(time_stamp, string[i:string.find(" ", i + 4)])
		for i in find_all(string, "n't"):
			print(time_stamp, string[string[:i].rfind(" ")+1:string.find(" ", i + 4)])

	return res

# check if a word is in the calibration spreadsheet
# returns (True, spreadsheet_word) or (False, None)
# A word's stem (default), synonyms, and similarity score to calibrated words are checked
def inScale(word, c_stem=True, c_synonyms=False, c_similarity=False):
	emotions = readEmotions(spreadsheet_path)

	ps = PorterStemmer()
	for e in emotions:
		if (c_stem and ps.stem(e) == ps.stem(word)) or \
			(c_synonyms and word in getSynonyms(e)) or \
			(c_similarity and similarEnough(word,e,0.7)):
			return True, e
	return False, None

# returns the synset (nltk wordnet) of a word
def getSynonyms(word):
	res = []
	for synset in wn.synsets(word):
		res += synset.lemma_names()
	return set(res)

# returns True if two words' path similarity (nltk wordnet) 
# is greater than or equal to the threshold
def similarEnough(word1, word2, threshold):
	max_similarity = 0
	for synset1 in wn.synsets(word1):
		for synset2 in wn.synsets(word2):
			curr = wn.path_similarity(synset1,synset2,simulate_root=True)
			if curr != None:
				if curr > max_similarity:
					max_similarity = curr
			

	return max_similarity >= threshold


# lst: a list of (word, emotion) tuple
# participant_num(int)
# NoEmotionRecognizedException: thrown if lst is [("no scalable emotion recognized", None)]
# returns a list of int: the calibrated value of each emotion word
# if word not calibrated by this participant, the entry in the return list is None
def toScale(lst, participant_num):
	emotions = readEmotions(spreadsheet_path)
	scale = readScale(spreadsheet_path, participant_num)

	res = []
	for item in lst:
		if not item[1]:
			raise NoEmotionRecognizedException

		num = scale[emotions.index(item[1])]
		if num != "":
			res.append(float(num))
		else:
			res.append(None)
	# print(res)
	return res


####################################
# Exception
####################################
class NoEmotionRecognizedException(Exception):
	pass


