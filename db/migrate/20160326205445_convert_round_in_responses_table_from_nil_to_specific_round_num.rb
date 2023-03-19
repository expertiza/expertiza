class ConvertRoundInResponsesTableFromNilToSpecificRoundNum < ActiveRecord::Migration[4.2]
  def change
    # 1st kind of assignment which has both 'review' and 'rereview' deadline type.
    # this kind of assignment only has one round of 'review' deadline.
    index = 0
    assignments = Assignment.where(['id in (?)', [16, 17, 18, 19, 20, 21, 23, 24, 25, 26, 27, 29, 30, 31, 33, 36, 39, 40, 45, 46, 47, 72, 73, 75, 90, 93, 94, 95, 100, 101, 112, 113, 124, 126, 203, 215, 217, 218, 220, 223, 224, 228, 229, 232, 233, 234, 236, 238, 239, 240, 241, 242, 246, 255, 256, 258, 260, 261, 266, 272, 275, 277, 279, 280, 281, 283, 284, 285, 287, 292, 296, 298, 299, 300, 303, 308, 309, 311, 320, 323, 399, 433, 435, 447, 481, 483, 484, 489, 497, 499, 516, 519, 522, 523, 524, 525, 526, 529, 531, 532, 533, 534, 537, 539, 544, 545, 546, 549, 551, 552, 553, 554, 556, 559, 560, 561, 564, 565, 573, 577, 581, 582, 585, 587, 588, 592, 593, 596, 599, 600, 601, 602, 673]])
    assignments.each do |assignment|
      response_maps = ResponseMap.where(reviewed_object_id: assignment.id, type: 'ReviewResponseMap')
      unless response_maps.empty?
        due_date = DueDate.where(['assignment_id = ? and deadline_type_id = ? and due_at is not null', assignment.id, 2]).first
      end
      response_maps.each do |response_map|
        index += 1
        responses = response_map.response
        responses.each do |response|
          if response.round.nil?
            if response.created_at.nil?
              response.round = 1
              response.save
            elsif response.created_at > due_date.due_at
              response.round = 2
              response.save
            else
              response.round = 1
              response.save
            end
          end
        end
      end
    end

    # 2nd kind of assignment which has only 'review' deadline type.
    # this kind of assignment only can have one or more rounds of 'review' deadlines.
    index = 0
    assignments = Assignment.where(['id in (?)', [2, 13, 15, 22, 28, 37, 38, 41, 42, 43, 44, 48, 50, 51, 52, 62, 64, 66, 67, 74, 76, 82, 84, 89, 92, 127, 128, 129, 130, 132, 134, 135, 136, 138, 139, 142, 143, 144, 145, 147, 148, 149, 150, 152, 156, 158, 159, 161, 162, 163, 164, 165, 166, 170, 171, 172, 175, 176, 177, 178, 181, 182, 183, 184, 185, 186, 187, 188, 189, 191, 192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 204, 205, 206, 207, 208, 209, 211, 212, 214, 216, 219, 221, 222, 226, 227, 230, 235, 237, 244, 245, 249, 250, 253, 257, 259, 262, 263, 265, 267, 268, 269, 270, 271, 274, 276, 278, 282, 288, 289, 290, 291, 293, 295, 297, 302, 304, 305, 306, 307, 310, 312, 313, 314, 317, 318, 319, 322, 324, 325, 326, 327, 328, 329, 330, 331, 332, 333, 336, 341, 344, 346, 357, 358, 359, 360, 361, 362, 363, 364, 365, 366, 367, 369, 370, 371, 372, 373, 374, 375, 376, 377, 378, 380, 381, 382, 386, 390, 393, 394, 395, 398, 403, 404, 406, 408, 409, 410, 411, 420, 421, 422, 423, 426, 427, 430, 432, 434, 437, 438, 439, 440, 441, 442, 443, 444, 445, 450, 452, 453, 454, 455, 457, 458, 463, 465, 466, 468, 469, 470, 471, 472, 473, 474, 475, 477, 479, 482, 487, 488, 490, 491, 492, 493, 494, 496, 498, 501, 502, 503, 505, 508, 509, 512, 514, 515, 517, 518, 520, 521, 527, 528, 536, 540, 541, 542, 547, 555, 562, 563, 570, 572, 574, 576, 580, 589, 590, 591, 594, 595, 597, 598, 603, 604, 605, 607, 608, 609, 610, 611, 616, 617, 618, 619, 621, 622, 624, 627, 628, 630, 631, 632, 633, 634, 635, 636, 637, 638, 643, 644, 648, 649, 650, 651, 652, 653, 654, 655, 656, 657, 658, 659, 661, 662, 663, 664, 665, 666, 667, 668, 669, 671, 674, 675, 676, 680, 681, 682, 683, 684, 685, 686, 687, 688, 690, 691, 692, 693, 695, 696, 697, 698, 699, 700, 701, 703, 704, 705, 706, 707, 709, 710, 711, 712, 713, 714, 716, 717, 718, 719, 720, 721, 722, 723, 724, 725, 728, 730, 732, 733, 734, 735, 736, 737, 738, 739, 740, 741, 742, 743, 744, 745, 749, 750, 751, 752, 753, 754, 755, 756, 757, 758, 759, 760, 761, 764, 765, 766, 768, 770]])
    assignments.each do |assignment|
      response_maps = ResponseMap.where(reviewed_object_id: assignment.id, type: 'ReviewResponseMap')
      unless response_maps.empty?
        due_dates = DueDate.where(['assignment_id = ? and deadline_type_id = ? and due_at is not null', assignment.id, 2])
        size = due_dates.size
      end
      response_maps.each do |response_map|
        index += 1
        responses = response_map.response
        responses.each do |response|
          if response.created_at.nil?
            response.round = 1
            response.save
            next
          end
          if response.round.nil? && size < 3
            if response.created_at <= due_dates[0].due_at
              response.round = 1
              response.save
            elsif response.created_at > due_dates[0].due_at
              response.round = 2
              response.save
            end
          elsif response.round.nil? && size >= 3
            if response.created_at <= due_dates[0].due_at
              response.round = 1
              response.save
            else
              if response.created_at <= due_dates[1].due_at
                response.round = 2
                response.save
              else
                response.round = 3
                response.save
              end
           end
          end
        end
      end
    end
  end
end
