import re

class transliteration:

  def __init__(self, translit):
    self.defective = False
    self.raw_translit = translit
    translit = translit.strip(' ')
    translit = translit.replace('source: ', 'source:')
    if ' ' in translit:
      self.defective = True
      return None
    for expt in ['_', '...', 'line', '(X', 'X)', '.X',
                 ' X', 'Xbr','-X', 'ṭ', 'ṣ', 'missing']:
      if expt in translit or expt.lower() in translit.lower():
        self.defective = True
        return None
    if translit.lower()!=translit:
      self.defective = True
      return None
    extra = re.compile('(\[|\]|\{\?\}|\{\!\}|\\\|/)')
    translit = extra.sub('', translit)
    translit = self.standardize_translit(translit)
    translit = self.remove_determinatives(translit)
    self.base_translit = translit
    self.sign_list = self.parse_signs(translit)
    for el in self.sign_list:
      if 'x' in el['value'].lower() and '×' not in el['value'].lower():
        self.defective = True
        return None
      if '(' in el['value']:
        pass
        print([self.raw_translit, self.base_translit, el['value'], self.sign_list])
    i=0
    while i < len(self.sign_list):
      self.sign_list[i] = self.get_unicode_index(self.sign_list[i])
      i+=1
    self.set_normalizations()

  def parse_signs(self, translit):
    signs_lst = []
    re_x_index = re.compile(r'(?P<a>[\w])x')
    re_x_sign = re.compile(r'(ₓ\(.+\))')
    re_brc = re.compile(r'(\(.+\))')
    re_source = re.compile(r'(?P<a>.+)(?P<b>\(source:)(?P<c>[^)]+)(?P<d>\))')
    re_index = re.compile(r'(?P<sign>[^\d]+)(?P<index>\d+)')
    re_brc_div = re.compile(r'(?P<a>\([^\)]+)(?P<b>-+)(?P<c>[^\(]+\))')
    if re_brc_div.search(translit):
      translit = re_brc_div.sub(lambda m: m.group().replace('-',"="),
                                translit)    
    for sign in list(filter(lambda x: x!='', translit.split('-'))):
      index=''
      emendation=''
      value_of=''
      if re_x_index.search(sign):
        sign = re_x_index.sub('\g<a>ₓ', sign)
      if 'ₓ(' in sign.lower():
        index='x'
        value_of = re_x_sign.search(sign).group().strip('ₓ()').replace('=',"-")
        sign = re_x_sign.sub('', sign)
      if re_brc.search(sign):
        value_of = re_brc.search(sign).group().strip('()').replace('=',"-")
        sign = re_brc.sub('', sign)
      if 'x' in sign.lower() and len(sign)>1:
        pass
      if re_source.search(sign):
        emendation = re_source.sub(r'\g<c>', sign).replace('=',"-")
        sign = re_source.sub(r'\g<a>', sign)
      if re_index.search(sign):
        i=0
        for x in re_index.finditer(sign):
          if i==0:
            index = x.groupdict()['index']
            sign = x.groupdict()['sign']
          else:
            pass
            #print(self.raw_translit, sign, i, x.groupdict()['sign'], x.groupdict()['index'])
          i+=1
      signs_lst.append({'value': sign,
                        'index': index,
                        'emendation': emendation,
                        'value_of': value_of
                        })
    return signs_lst

  def set_normalizations(self):
    norm_flat_lst = [s['value'] for s in self.sign_list]
    norm_unicode_lst = [s['u_sign'] for s in self.sign_list]
    i = 0
    self.normalization = ''
    self.normalization_u = ''
    while i < len(norm_flat_lst):
      if self.normalization:
        if self.normalization[-1]==norm_flat_lst[i][0]:
          self.normalization+=norm_flat_lst[i][1:]
          self.normalization_u+=norm_unicode_lst[i][1:]
        else:
          self.normalization+=norm_flat_lst[i]
          self.normalization_u+=norm_unicode_lst[i]          
      else:
        self.normalization+=norm_flat_lst[i]
        self.normalization_u+=norm_unicode_lst[i]
      i+=1
  
  def standardize_translit(self, translit):
    std_dict = {'š':'c', 'ŋ':'j', '₀':'0', '₁':'1', '₂':'2',
                '₃':'3', '₄':'4', '₅':'5', '₆':'6', '₇':'7',
                '₈':'8', '₉':'9', '+':'-', 'Š':'C', 'Ŋ':'J',
                '·':'', '°':''}
    for key in std_dict.keys():
      translit = translit.replace(key, std_dict[key])
    times = re.compile(r'(?P<a>[\w])x(?P<b>[\w])')
    if times.search(translit):
      translit = times.sub('\g<a>×\g<b>', translit)
    return translit

  def get_unicode_index(self, sign_dict):
    vow_lst = ['a', 'A', 'e', 'E', 'i', 'I', 'u', 'U']
    re_last_vow = re.compile(r'(%s)' %('|'.join(vow_lst)))
    sign_dict['u_sign'] = sign_dict['value']
    if sign_dict['index'] not in ['', 'x']:
      val = sign_dict['value']
      v = re_last_vow.findall(val)[-1]
      esc = chr((vow_lst.index(v)+1)*1000+int(sign_dict['index']))
      i = val.rfind(v)
      u_sign = '%s%s%s' %(val[:i], esc, val[i+1:])
      sign_dict['u_sign']=u_sign
    return sign_dict    

  def revert_unicode_index(self, u_sign):
    vow_lst = ['a', 'A', 'e', 'E', 'i', 'I', 'u', 'U']    
    i =0
    while i < len(u_sign):
      n = ord(u_sign[i])
      if n > 1000:
        vow_i = int(str(n)[0])-1
        index = int(str(n)[2:])
        return {'value': u_sign[:i]+vow_lst[vow_i]+u_sign[i+1:],
                'index': index}
      i+=1

  def remove_determinatives(self, translit):
    det = re.compile('(\{.*?\})')
    return det.sub('', translit)
