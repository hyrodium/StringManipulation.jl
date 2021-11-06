# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Functions to split strings.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

export split_string

"""
    split_string(str::AbstractString, size::Int)

Split the string `str` after a number of characters that have a specific
printable `size`. This function returns a tuple with two strings: before and
after the split point.

The algorithm ensures that the printable width of the first returned string will
always be equal `size`, unless `size` is negative or larger than the printable
size of `str`. In the first case, the first string is empty, whereas, in the
second case, the first string is equal to `str`.

!!! note
    If the character in the split point needs more than 1 character to be
    printed (like some UTF-8 characters), then everything will be filled with
    spaces.
"""
function split_string(str::AbstractString, size::Int)
    buf₀ = IOBuffer() # .......... Buffer with the string before the split point
    buf₁ = IOBuffer() # ........... Buffer with the string after the split point
    state = :text

    for c in str
        if size ≤ 0
            print(buf₁, c)
        else
            state = _process_string_state(c, state)

            if state == :text
                cw = textwidth(c)
                size -= cw

                # If `size` is negative, then it means that we have a character
                # that occupies more than 1 character. In this case, we fill the
                # string with space.
                if size < 0
                    print(buf₀, " "^(-size))
                    print(buf₁, " "^(cw + size))
                    size = 0
                    continue
                end
            end

            print(buf₀, c)
        end
    end

    return String(take!(buf₀)), String(take!(buf₁))
end
