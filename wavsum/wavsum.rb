data = ARGF.read
keys = %w[id totallength wavefmt format
          pcm channels frequency bytes_per_second
          bytes_by_capture bits_per_sample
          data bytes_in_data sum
]
values = data.unpack 'Z4 i Z8 i s s i i s s Z4 i s*'
sum = values.drop(12).map(&:abs).inject(:+)
keys.zip(values.take(12) << sum) {|k, v|
      puts "#{k.ljust 17}: #{v}"
}
